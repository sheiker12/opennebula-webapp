#!/bin/bash
cd /app/webapp
nohup gunicorn --bind 0.0.0.0:5000 app:app > /var/log/webapp.log 2>&1 &
