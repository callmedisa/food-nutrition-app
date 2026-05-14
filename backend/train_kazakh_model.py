"""
Обучает EfficientNet-B0 на датасете казахских блюд.

Запуск:
    python3 train_kazakh_model.py

Результат:
    kazakh_model.pth  — веса модели
    kazakh_classes.json — список классов
"""

import ssl
ssl._create_default_https_context = ssl._create_unverified_context  # macOS Python 3.14 fix

import json
import time
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, random_split
from torchvision import datasets, transforms, models
from pathlib import Path

DATASET_DIR  = "./kazakh_dataset"
MODEL_OUT    = "./kazakh_model.pth"
CLASSES_OUT  = "./kazakh_classes.json"

BATCH_SIZE   = 32
EPOCHS_HEAD  = 8    # фаза 1: обучаем только голову
EPOCHS_FINE  = 10   # фаза 2: тонкая настройка всей сети
LR_HEAD      = 1e-3
LR_FINE      = 5e-5
VAL_SPLIT    = 0.2
IMG_SIZE     = 224

device = (
    torch.device("mps")  if torch.backends.mps.is_available() else
    torch.device("cuda") if torch.cuda.is_available() else
    torch.device("cpu")
)
print(f"Устройство: {device}")

IMAGENET_MEAN = [0.485, 0.456, 0.406]
IMAGENET_STD  = [0.229, 0.224, 0.225]

train_tf = transforms.Compose([
    transforms.RandomResizedCrop(IMG_SIZE, scale=(0.7, 1.0)),
    transforms.RandomHorizontalFlip(),
    transforms.ColorJitter(brightness=0.25, contrast=0.25, saturation=0.25, hue=0.05),
    transforms.RandomRotation(15),
    transforms.ToTensor(),
    transforms.Normalize(IMAGENET_MEAN, IMAGENET_STD),
])

val_tf = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(IMG_SIZE),
    transforms.ToTensor(),
    transforms.Normalize(IMAGENET_MEAN, IMAGENET_STD),
])


def load_datasets(root: str):
    full = datasets.ImageFolder(root, transform=train_tf)
    n_val = int(len(full) * VAL_SPLIT)
    n_train = len(full) - n_val
    train_ds, val_ds = random_split(
        full, [n_train, n_val],
        generator=torch.Generator().manual_seed(42),
    )
    # val использует val_tf — нужно переопределить transform
    val_ds.dataset = datasets.ImageFolder(root, transform=val_tf)
    return train_ds, val_ds, full.classes


def build_model(num_classes: int) -> nn.Module:
    model = models.efficientnet_b0(weights=models.EfficientNet_B0_Weights.IMAGENET1K_V1)
    in_features = model.classifier[1].in_features
    model.classifier[1] = nn.Linear(in_features, num_classes)
    return model


def train_epoch(model, loader, criterion, optimizer):
    model.train()
    total_loss, correct, total = 0.0, 0, 0
    for imgs, labels in loader:
        imgs, labels = imgs.to(device), labels.to(device)
        optimizer.zero_grad()
        out = model(imgs)
        loss = criterion(out, labels)
        loss.backward()
        optimizer.step()
        total_loss += loss.item() * len(labels)
        correct += (out.argmax(1) == labels).sum().item()
        total += len(labels)
    return total_loss / total, correct / total


@torch.no_grad()
def eval_epoch(model, loader, criterion):
    model.eval()
    total_loss, correct, total = 0.0, 0, 0
    for imgs, labels in loader:
        imgs, labels = imgs.to(device), labels.to(device)
        out = model(imgs)
        loss = criterion(out, labels)
        total_loss += loss.item() * len(labels)
        correct += (out.argmax(1) == labels).sum().item()
        total += len(labels)
    return total_loss / total, correct / total


def run_phase(model, train_loader, val_loader, epochs, lr, phase_name, frozen=False):
    if frozen:
        for p in model.features.parameters():
            p.requires_grad = False
        params = model.classifier.parameters()
    else:
        for p in model.parameters():
            p.requires_grad = True
        params = model.parameters()

    optimizer = torch.optim.AdamW(params, lr=lr, weight_decay=1e-4)
    scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=epochs)
    criterion = nn.CrossEntropyLoss()

    best_acc = 0.0
    print(f"\n── {phase_name} ({epochs} эпох, lr={lr}) ──")
    for ep in range(1, epochs + 1):
        t0 = time.time()
        tr_loss, tr_acc = train_epoch(model, train_loader, criterion, optimizer)
        va_loss, va_acc = eval_epoch(model, val_loader, criterion)
        scheduler.step()
        elapsed = time.time() - t0
        print(f"  Эп {ep:2d}/{epochs}  "
              f"train {tr_acc:.1%} ({tr_loss:.3f})  "
              f"val {va_acc:.1%} ({va_loss:.3f})  "
              f"{elapsed:.0f}с")
        if va_acc > best_acc:
            best_acc = va_acc
            torch.save(model.state_dict(), MODEL_OUT)
    print(f"  Лучшая val accuracy: {best_acc:.1%}")
    return best_acc


def main():
    dataset_path = Path(DATASET_DIR)
    if not dataset_path.exists():
        print(f"Датасет не найден: {dataset_path.resolve()}")
        return

    print(f"Загрузка датасета из {dataset_path.resolve()}...")
    train_ds, val_ds, classes = load_datasets(DATASET_DIR)
    print(f"Классов: {len(classes)}: {classes}")
    print(f"Train: {len(train_ds)}, Val: {len(val_ds)}")

    train_loader = DataLoader(train_ds, batch_size=BATCH_SIZE, shuffle=True, num_workers=2)
    val_loader   = DataLoader(val_ds,   batch_size=BATCH_SIZE, shuffle=False, num_workers=2)

    model = build_model(len(classes)).to(device)

    # Фаза 1: замороженный backbone — обучаем только классификатор
    run_phase(model, train_loader, val_loader,
              epochs=EPOCHS_HEAD, lr=LR_HEAD,
              phase_name="Фаза 1: обучение головы", frozen=True)

    # Фаза 2: разморозка всей сети — тонкая настройка
    model.load_state_dict(torch.load(MODEL_OUT, map_location=device))
    run_phase(model, train_loader, val_loader,
              epochs=EPOCHS_FINE, lr=LR_FINE,
              phase_name="Фаза 2: тонкая настройка", frozen=False)

    # Загружаем лучшую модель и сохраняем классы
    model.load_state_dict(torch.load(MODEL_OUT, map_location=device))
    with open(CLASSES_OUT, "w", encoding="utf-8") as f:
        json.dump(classes, f, ensure_ascii=False, indent=2)

    print(f"\n✓ Модель сохранена: {MODEL_OUT}")
    print(f"✓ Классы сохранены: {CLASSES_OUT}")


if __name__ == "__main__":
    main()
