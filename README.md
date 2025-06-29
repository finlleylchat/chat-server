# Go Application

Современное Go приложение с полным CI/CD пайплайном, контейнеризацией и Kubernetes деплоем.

## 🚀 Быстрый старт

### Локальная разработка

```bash
# Установка зависимостей
make dev

# Запуск приложения
make run

# Запуск тестов
make test

# Проверка кода
make lint
```

### Docker

```bash
# Сборка и запуск в Docker
docker-compose up

# Продакшн сборка
make docker-build
make docker-run
```

## 🛠 Разработка

### Требования

- Go 1.23+
- Docker & Docker Compose
- Make
- kubectl (для Kubernetes деплоя)

### Структура проекта

```
.
├── cmd/                    # Точки входа приложения
├── internal/               # Внутренняя логика
├── pkg/                    # Публичные пакеты
├── k8s/                    # Kubernetes манифесты
├── .github/workflows/      # CI/CD пайплайны
├── Dockerfile              # Многоэтапная сборка
├── docker-compose.yml      # Локальная разработка
└── Makefile               # Автоматизация задач
```

### Команды Make

```bash
make help              # Показать все команды
make dev               # Настройка окружения разработки
make build             # Сборка приложения
make build-all         # Сборка для всех платформ
make test              # Запуск тестов
make test-coverage     # Тесты с покрытием
make lint              # Проверка кода
make security          # Сканирование безопасности
make clean             # Очистка артефактов
make deps              # Управление зависимостями
make ci                # Локальный CI пайплайн
```

## 🔧 CI/CD

### GitHub Actions

Пайплайн включает:

- **Security**: Сканирование уязвимостей с Trivy
- **Test**: Матричное тестирование на разных ОС и версиях Go
- **Build**: Кросс-платформенная сборка
- **Lint**: Проверка кода с golangci-lint
- **Dependency Check**: Проверка зависимостей
- **Release**: Автоматические релизы при тегах

### Триггеры

- Push в `main`, `master`, `develop`
- Pull Request в `main`, `master`, `develop`
- Теги `v*` (автоматический релиз)

## 🐳 Контейнеризация

### Docker

- **Многоэтапная сборка** для минимизации размера
- **Scratch образ** для безопасности
- **Оптимизированные слои** для кэширования

### Docker Compose

```bash
# Разработка
docker-compose up app

# Продакшн
docker-compose up app-prod
```

## ☸️ Kubernetes

### Деплой

```bash
# Применение манифестов
kubectl apply -f k8s/

# Проверка статуса
kubectl get pods -l app=app
```

### Особенности

- **HPA**: Автоматическое масштабирование
- **Security Context**: Запуск без root
- **Health Checks**: Liveness и Readiness пробы
- **Network Policy**: Ограничение сетевого трафика
- **Resource Limits**: Ограничения CPU/памяти

## 🔒 Безопасность

- Сканирование уязвимостей в CI/CD
- Non-root контейнеры
- Read-only файловая система
- Network policies
- Минимальные привилегии

## 📊 Мониторинг

- Health check эндпоинты
- Метрики ресурсов
- Логирование структурированное
- Трейсинг (готов к интеграции)

## 🚀 Деплой

### Локальный

```bash
make release
```

### Kubernetes

```bash
# Сборка и пуш образа
make docker-push

# Деплой в кластер
kubectl apply -f k8s/
```

## 📝 Лицензия

MIT License 