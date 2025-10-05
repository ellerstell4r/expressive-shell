#!/usr/bin/env bash
options="Заблокировать\nВыйти\nСпящий режим\nПерезагрузить\nВыключить\nОтмена"
chosen="$(echo -e "$options" | rofi -dmenu -p "Питание" -mesg "Выберите действие")"
case $chosen in
    "Выключить")
        systemctl poweroff
        ;;
    "Перезагрузить")
        systemctl reboot
        ;;
    "Спящий режим")
        systemctl suspend
        ;;
    "Выйти")
        if [[ "$DESKTOP_SESSION" == 'awesome' ]]; then
            echo 'awesome.quit()' | awesome-client
        else
            loginctl terminate-user $USER
        fi
        ;;
    "Заблокировать")
        if command -v betterlockscreen &> /dev/null; then
            betterlockscreen -l blur
        elif command -v i3lock &> /dev/null; then
            i3lock -c 000000
        else
            xset dpms force off
        fi
        ;;
    "Отмена")
        exit 0
        ;;
esac
