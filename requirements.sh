#!/bin/bash

# Скрипт для установки Python-пакетов и зависимостей через apt-get

set -e  # Прерывать выполнение при ошибках

# Список пакетов для установки
PACKAGES=(
    python3-psycopg2
    python3-toml
    gunicorn
    python3-flask
)

# Функция для проверки установленных пакетов
check_installed() {
    for pkg in "${PACKAGES[@]}"; do
        if dpkg -l | grep -q "^ii  $pkg "; then
            echo "✓ $pkg уже установлен"
        else
            echo "✗ $pkg не установлен"
            return 1
        fi
    done
    return 0
}

# Проверяем, запущено ли с правами root
if [ "$(id -u)" -ne 0 ]; then
    echo "Этот скрипт требует прав root. Запустите с sudo." >&2
    exit 1
fi

echo "=== Установка пакетов через apt-get ==="
echo "Список пакетов: ${PACKAGES[*]}"

# Проверяем, не установлены ли уже пакеты
if check_installed; then
    echo "Все пакеты уже установлены. Выход."
    exit 0
fi

# Обновляем информацию о пакетах
echo "Обновление списка пакетов..."
apt-get update

# Устанавливаем пакеты
echo "Установка пакетов..."
apt-get install -y "${PACKAGES[@]}"

# Проверяем успешность установки
if check_installed; then
    echo "=== Установка завершена успешно ==="
    
    # Дополнительная проверка версий Python-пакетов
    echo "Проверка версий Python-пакетов:"
    python3 -c "
try:
    import psycopg2; print(f'psycopg2: {psycopg2.__version__}')
except ImportError:
    print('psycopg2: не установлен')
    
try:
    import toml; print(f'toml: {toml.__version__}')
except ImportError:
    print('toml: не установлен')
    
try:
    import flask; print(f'Flask: {flask.__version__}')
except ImportError:
    print('Flask: не установлен')
    
try:
    import gunicorn; print(f'Gunicorn: {gunicorn.__version__}')
except ImportError:
    print('Gunicorn: не установлен')
"
else
    echo "Ошибка: не все пакеты были установлены!" >&2
    exit 1
fi

# Проверяем доступность команд
echo "Проверка доступности команд:"
command -v gunicorn && echo "Gunicorn доступен в PATH" || echo "Gunicorn не найден в PATH"

exit 0
