"""
Скрипт для загрузки датасета Food-101 через TensorFlow Datasets
"""

import tensorflow_datasets as tfds
import tensorflow as tf
import os
from pathlib import Path

# Настройка путей
PROJECT_ROOT = Path(__file__).parent.parent
DATA_DIR = PROJECT_ROOT / "data"
DATA_DIR.mkdir(exist_ok=True)

print("=" * 60)
print("Загрузка датасета Food-101")
print("=" * 60)

# Загрузка датасета
# По умолчанию загружается в ~/tensorflow_datasets/
# Но можно указать свою директорию через data_dir
print("\n1. Загрузка датасета (это может занять некоторое время, ~5GB)...")

# Загрузка с информацией о датасете
dataset, info = tfds.load(
    'food101',
    split=['train', 'validation'],
    shuffle_files=True,
    with_info=True,
    data_dir=str(DATA_DIR / "tensorflow_datasets"),
    download=True
)

train_dataset, val_dataset = dataset

print("\n✓ Датасет загружен успешно!")
print("\n" + "=" * 60)
print("Информация о датасете:")
print("=" * 60)

# Информация о датасете
print(f"\nНазвание: {info.name}")
print(f"Описание: {info.description}")
print(f"Версия: {info.version}")
print(f"Количество классов: {info.features['label'].num_classes}")
print(f"\nРазмеры splits:")
print(f"  - Train: {info.splits['train'].num_examples} изображений")
print(f"  - Validation: {info.splits['validation'].num_examples} изображений")

# Список категорий еды
print(f"\n\nКатегории еды ({len(info.features['label'].names)}):")
for i, label in enumerate(info.features['label'].names[:10]):
    print(f"  {i}. {label}")
print(f"  ... и еще {len(info.features['label'].names) - 10} категорий")

# Сохранение списка категорий
categories_file = DATA_DIR / "food_categories.txt"
with open(categories_file, 'w', encoding='utf-8') as f:
    for label in info.features['label'].names:
        f.write(f"{label}\n")

print(f"\n✓ Список категорий сохранен в: {categories_file}")

# Пример: проверка первого изображения
print("\n" + "=" * 60)
print("Проверка данных...")
print("=" * 60)

for example in train_dataset.take(1):
    image = example['image']
    label = example['label']

    print(f"\nПример изображения:")
    print(f"  - Размер: {image.shape}")
    print(f"  - Тип данных: {image.dtype}")
    print(f"  - Метка класса: {label.numpy()}")
    print(f"  - Название: {info.features['label'].int2str(label.numpy())}")

print("\n" + "=" * 60)
print("✓ Все готово!")
print("=" * 60)
print(f"\nДатасет находится в: {DATA_DIR / 'tensorflow_datasets'}")
print("\nСледующие шаги:")
print("  1. Изучить данные в Jupyter notebook")
print("  2. Создать модель для классификации")
print("  3. Обучить модель на датасете")
print("\n" + "=" * 60)
