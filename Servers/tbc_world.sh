#
# Project: Restarter 
# Author: Slavomir Strnad
# GitHub: https://github.com/Rimovals2
# Description:
#   - Core logic for event management, including event activation,
#     notifications, boss management, and expiration handling.
# License: GNU General Public License v3.0
#   - You must retain this header when modifying or redistributing the code.
#   - See LICENSE file for more details.
# 

#!/bin/bash

# Cesta k aplikaci
APP_DIR="/home/tbcuser/ftp/bin"
APP_EXEC="./mangosd"
LOG_FILE="/var/log/mangosd_restart.log"
SLEEP_TIME=20

# Funkce pro čisté ukončení při zachycení signálu (např. CTRL+C)
cleanup() {
    echo "$(date): Skript ukončen uživatelem." >> "$LOG_FILE"
    exit 0
}

# Nastavení zachycení signálů
trap cleanup SIGINT SIGTERM

# Nekonečný cyklus
while true; do
  # Přesun do složky
  cd "$APP_DIR" || { echo "Cesta $APP_DIR neexistuje."; exit 1; }
  
  # Spuštění programu a logování
  echo "$(date): Spouštím $APP_EXEC" >> "$LOG_FILE"
  $APP_EXEC
  
  # Kontrola návratového kódu
  EXIT_CODE=$?
  if [ $EXIT_CODE -ne 0 ]; then
    echo "$(date): $APP_EXEC skončil s chybou (kód $EXIT_CODE)" >> "$LOG_FILE"
  else
    echo "$(date): $APP_EXEC se ukončil čistě." >> "$LOG_FILE"
  fi

  # Pauza
  echo "$(date): Čekám $SLEEP_TIME sekund před restartem." >> "$LOG_FILE"
  sleep $SLEEP_TIME
done