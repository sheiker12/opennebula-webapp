from flask import Flask, jsonify, render_template
import psycopg2
import toml
import os

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
    
    return jsonify({
        "status": "running",
        "db_status": db_status,
        "host": os.uname().nodename
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=config['server']['port'])
