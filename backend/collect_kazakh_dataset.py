"""
Скачивает фото казахских блюд через DuckDuckGo Images.

Установка:
    pip3 install ddgs requests

Запуск:
    python3 collect_kazakh_dataset.py
"""

import os
import time
import requests
import hashlib
from ddgs import DDGS

DISHES = {
    "beshbarmak": ["бешбармак", "beshbarmak dish"],
    "bauyrsak":   ["баурсак", "baursak kazakh"],
    "kuirdak":    ["куырдак", "kuirdak kazakh"],
    "manty":      ["манты казахские", "manty dumplings"],
    "samsa":      ["самса казахская", "самса пирожок", "samsa pastry", "самса рецепт"],
    "lagman":     ["лагман", "lagman noodles", "лагман рецепт", "лагман суп"],
    "sorpa":      ["сорпа суп", "sorpa soup", "казахский бульон", "сорпа казахская"],
    "kazy":       ["казы колбаса", "kazy sausage"],
    "naryn":      ["нарын блюдо", "naryn dish"],
    "shelpek":    ["шелпек", "shelpek kazakh", "шелпек лепёшка", "казахские лепёшки"],
    "plov":       ["плов", "plov pilaf"],
    "shashlik":   ["шашлык", "shashlik kebab"],
    "kurt":       ["курт казахский", "kurt cheese"],
    "irimshik":   ["іріімшік", "irimshik kazakh"],
}

OUTPUT_DIR   = "./kazakh_dataset"
TARGET_COUNT = 120  # фото на блюдо
PER_QUERY    = 80   # сколько брать с каждого запроса


def download_image(url: str, folder: str, idx: int) -> bool:
    try:
        headers = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"}
        resp = requests.get(url, headers=headers, timeout=10)
        if resp.status_code != 200:
            return False
        content_type = resp.headers.get("content-type", "")
        if "jpeg" in content_type or "jpg" in content_type:
            ext = "jpg"
        elif "png" in content_type:
            ext = "png"
        elif "webp" in content_type:
            ext = "webp"
        else:
            # Try to guess from URL
            url_lower = url.lower().split("?")[0]
            if url_lower.endswith(".jpg") or url_lower.endswith(".jpeg"):
                ext = "jpg"
            elif url_lower.endswith(".png"):
                ext = "png"
            elif url_lower.endswith(".webp"):
                ext = "webp"
            else:
                return False

        name = hashlib.md5(url.encode()).hexdigest()[:12]
        path = os.path.join(folder, f"{idx:04d}_{name}.{ext}")
        with open(path, "wb") as f:
            f.write(resp.content)
        return True
    except Exception:
        return False


def collect_dish(dish_name: str, queries: list[str]):
    folder = os.path.join(OUTPUT_DIR, dish_name)
    os.makedirs(folder, exist_ok=True)

    existing_files = [f for f in os.listdir(folder) if f.endswith((".jpg", ".jpeg", ".png", ".webp"))]
    existing = len(existing_files)

    if existing >= TARGET_COUNT:
        print(f"  ✓ {dish_name}: уже {existing} фото — пропускаем")
        return

    need = TARGET_COUNT - existing
    print(f"  🔍 {dish_name}: нужно ещё {need} фото...")

    seen_urls: set[str] = set()
    urls: list[str] = []

    with DDGS() as ddgs:
        for query in queries:
            if len(urls) >= need + 20:
                break
            try:
                results = list(ddgs.images(
                    query,
                    max_results=PER_QUERY,
                    safesearch="off",
                ))
                for r in results:
                    img_url = r.get("image", "")
                    if img_url and img_url not in seen_urls:
                        seen_urls.add(img_url)
                        urls.append(img_url)
                print(f"     «{query}»: {len(results)} результатов")
                time.sleep(1)
            except Exception as e:
                print(f"     «{query}»: ошибка — {e}")

    print(f"     Всего уникальных URL: {len(urls)}, скачиваю...")

    saved = 0
    for i, url in enumerate(urls[:need + 20]):
        if saved >= need:
            break
        if download_image(url, folder, existing + saved + 1):
            saved += 1
        if (i + 1) % 20 == 0:
            print(f"     Скачано: {saved}/{need}")

    total = existing + saved
    status = "✓" if total >= 80 else "⚠ мало"
    print(f"  {status} {dish_name}: скачано {saved}, итого {total} фото")


def main():
    print(f"Датасет: {os.path.abspath(OUTPUT_DIR)}")
    print(f"Блюд: {len(DISHES)}, цель: {TARGET_COUNT} фото каждое\n")

    for dish_name, queries in DISHES.items():
        collect_dish(dish_name, queries)
        time.sleep(2)  # пауза между блюдами

    # Итоговая статистика
    print("\n" + "=" * 40)
    total_all = 0
    for dish_name in DISHES:
        folder = os.path.join(OUTPUT_DIR, dish_name)
        if os.path.exists(folder):
            count = len([f for f in os.listdir(folder) if f.endswith((".jpg", ".jpeg", ".png", ".webp"))])
            total_all += count
            mark = "✓" if count >= 80 else "⚠"
            print(f"  {mark} {dish_name}: {count} фото")
    print(f"\nВсего: {total_all} фото")
    print(f"Путь: {os.path.abspath(OUTPUT_DIR)}")


if __name__ == "__main__":
    main()