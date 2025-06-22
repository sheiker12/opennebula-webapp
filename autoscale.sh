#!/bin/bash

# Настройки
WEB_APP1_IP="172.16.100.2"
WEB_APP2_IP="172.16.100.3"
CPU_THRESHOLD="50.0"
RUN_SCRIPT="/usr/local/bin/run_webapp.sh"
STOP_SCRIPT="/usr/local/bin/stop_webapp.sh"
USERNAME="root"

# Функция для получения загрузки CPU
get_cpu_usage() {
    ssh $USERNAME@"$1" "sudo top -bn1 | grep 'Cpu(s)' | awk '{print 100 - \$4}'"
}

# Получаем загрузку CPU с WEB_APP1
CPU=$(get_cpu_usage $WEB_APP1_IP)

echo "CPU на $WEB_APP1_IP: $CPU"

# Проверяем загрузку CPU
if (( $(echo "$CPU > $CPU_THRESHOLD" | bc -l) )); then
    echo "High load. Starting web_app2..."
    ssh $USERNAME@"$WEB_APP2_IP" "sudo $RUN_SCRIPT"
else
    echo "Low load. Stopping web_app2..."
    ssh $USERNAME@"$WEB_APP2_IP" "sudo $STOP_SCRIPT"
fi

