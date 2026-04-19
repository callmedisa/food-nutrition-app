#!/bin/bash
# Скрипт для проверки статуса загрузки датасета

echo "=========================================="
echo "Статус загрузки датасета Food-101"
echo "=========================================="
echo ""

if [ -f dataset_download.log ]; then
    echo "Последние строки из лога загрузки:"
    echo ""
    tail -5 dataset_download.log | grep -E "Dl Size|Загрузка|готово|Все готово" || tail -5 dataset_download.log
    echo ""
else
    echo "❌ Файл лога не найден"
    echo ""
fi

echo "=========================================="
echo "Проверка файлов датасета:"
echo "=========================================="
echo ""

if [ -d "data/tensorflow_datasets/food101" ]; then
    echo "✅ Директория датасета найдена"
    du -sh data/tensorflow_datasets/food101/ 2>/dev/null || echo "Подсчет размера..."
    echo ""

    if [ -f "data/food_categories.txt" ]; then
        echo "✅ Файл с категориями еды создан"
        echo "Количество категорий: $(wc -l < data/food_categories.txt)"
    else
        echo "⏳ Файл с категориями еще не создан"
    fi
else
    echo "⏳ Директория датасета еще не создана"
    echo "Загрузка продолжается..."
fi

echo ""
echo "=========================================="
echo "Для просмотра полного лога в реальном времени:"
echo "  tail -f dataset_download.log"
echo "=========================================="
