import netifaces
from flask import Flask, jsonify, render_template
import psycopg2
import toml

app = Flask(__name__)

# Загрузка конфигурации
config = toml.load('config.toml')

def get_db_connection():
    conn = psycopg2.connect(
        host=config['database']['host'],
        database=config['database']['dbname'],
        user=config['database']['user'],
        password=config['database']['password']
    )
    return conn

def get_eth0_ip():
    """Получает IP-адрес интерфейса eth0."""
    try:
        interfaces = netifaces.interfaces()
        if 'eth0' not in interfaces:
            return "Интерфейс eth0 не найден"

        iface = 'eth0'
        addresses = netifaces.ifaddresses(iface)

        if netifaces.AF_INET not in addresses:
            return "Интерфейс eth0 не имеет IPv4-адреса"

        ip_address = addresses[netifaces.AF_INET][0]['addr']
        return ip_address

    except Exception as e:
        return f"Ошибка: {str(e)}"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/status')
def status():
    try:
        # Проверка подключения к БД
        conn = get_db_connection()
        conn.close()
        db_status = "OK"
    except Exception as e:
        db_status = f"Error: {str(e)}"

    host_ip = get_eth0_ip()

    status_data = {
        "status": "running",
        "db_status": db_status,
        "host": host_ip
    }

    return render_template('status.html', status_data=status_data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=config['server']['port'])

