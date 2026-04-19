# Food Nutrition App - Приложение для определения БЖУ по фото еды

Мобильное приложение для распознавания еды по фотографии и определения БЖУ (белки, жиры, углеводы) и калорийности.

## Структура проекта

```
food-nutrition-app/
├── ml_model/          # ML модель для распознавания еды
├── backend/           # Backend API (FastAPI)
├── mobile_app/        # Flutter мобильное приложение
├── data/              # Датасеты и данные
├── notebooks/         # Jupyter notebooks для экспериментов
└── requirements.txt   # Python зависимости
```

## Быстрый старт

### 1. Установка зависимостей

```bash
# Создать виртуальное окружение
python3 -m venv venv
source venv/bin/activate  # для Linux/Mac
# или
venv\Scripts\activate     # для Windows

# Установить библиотеки
pip install -r requirements.txt
```

### 2. Загрузка датасета Food-101

```bash
python notebooks/download_dataset.py
```

Это скачает ~5GB датасет Food-101 с 101 категорией еды и 101,000 изображениями.

## Датасет

**Food-101**:
- 101 категория еды
- 75,750 обучающих изображений
- 25,250 валидационных изображений
- Источник: ETH Zurich

## Технологический стек

- **ML**: TensorFlow/Keras, TensorFlow Datasets
- **Backend**: FastAPI, Python
- **Mobile**: Flutter, Dart
- **Database**: PostgreSQL (планируется)

## Roadmap

- [x] Создание структуры проекта
- [ ] Загрузка датасета Food-101
- [ ] Исследование данных (EDA)
- [ ] Создание и обучение ML модели
- [ ] Разработка Backend API
- [ ] Разработка Flutter приложения
- [ ] Интеграция БЖУ базы данных
- [ ] Тестирование и деплой

