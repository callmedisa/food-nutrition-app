# Начало работы с проектом

## Текущее состояние

- ✅ Структура проекта создана
- ✅ TensorFlow и TensorFlow Datasets установлены
- ⏳ Датасет Food-101 скачивается (~5GB, может занять 15-30 минут)

## Проверка статуса загрузки датасета

Датасет скачивается в фоновом режиме. Проверить статус:

```bash
tail -f dataset_download.log
```

Или просто посмотреть последние строки:

```bash
tail dataset_download.log
```

Датасет сохраняется в: `data/tensorflow_datasets/food101/`

## Следующие шаги

### 1. После загрузки датасета

Проверьте, что датасет загружен успешно:
```bash
ls -la data/tensorflow_datasets/food101/2.0.0/
```

Должны появиться файлы с изображениями и метаданными.

### 2. Исследование данных (EDA)

Создайте Jupyter notebook для анализа:
```bash
jupyter notebook notebooks/
```

Или используйте готовый скрипт для просмотра примеров:
```bash
python3 notebooks/explore_dataset.py
```

### 3. Создание ML модели

Следующая задача - создать и обучить модель для классификации еды:

- Transfer learning с использованием MobileNetV2 или EfficientNet
- Оптимизация для мобильных устройств
- Конвертация в TensorFlow Lite

### 4. Backend API

После обучения модели:
- FastAPI сервер для обработки запросов
- Endpoint для загрузки фото
- Интеграция модели
- База данных БЖУ

### 5. Flutter приложение

Финальный этап:
- UI для камеры
- Отправка фото на сервер
- Отображение результатов (БЖУ, калории)

## Полезные команды

### Проверка установленных библиотек
```bash
pip3 list | grep tensorflow
```

### Запуск Python интерпретатора
```bash
python3
>>> import tensorflow as tf
>>> print(tf.__version__)
```

### Структура проекта
```
food-nutrition-app/
├── ml_model/          # Модели машинного обучения
├── backend/           # Backend API (FastAPI)
├── mobile_app/        # Flutter приложение
├── data/              # Датасеты
│   ├── tensorflow_datasets/
│   └── food_categories.txt
├── notebooks/         # Эксперименты и анализ
└── requirements.txt
```

## Ресурсы

- Food-101 paper: https://data.vision.ee.ethz.ch/cvl/datasets_extra/food-101/
- TensorFlow Datasets: https://www.tensorflow.org/datasets
- Flutter: https://flutter.dev
- FastAPI: https://fastapi.tiangolo.com

## Timeline (2 месяца)

**Неделя 1-2**: ML модель
- ✅ Загрузка датасета
- ⏳ EDA и препроцессинг
- ⏳ Transfer learning
- ⏳ Обучение модели

**Неделя 3**: Backend
- ⏳ FastAPI сервер
- ⏳ Интеграция модели
- ⏳ База БЖУ

**Неделя 4-5**: Flutter приложение
- ⏳ UI
- ⏳ Интеграция с backend
- ⏳ Тестирование

**Неделя 6-8**: Улучшения и документация
- ⏳ Оптимизация
- ⏳ Тестирование
- ⏳ Документация для диссертации
