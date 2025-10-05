<h1 align="center">expressive-shell</h1>
<details>Это тестовые дотфайлы, созданные чтобы проверить мои умения. Но вы все равно можете использовать эти дотфайлы.</details>

<h2 align="center">Установка</h2>

- Клонируйте репозиторий:

  ```
  git clone https://github.com/ellerstell4r/expressive-shell
  ```

- Запустите скрипт установки:

  ```
  cd expressive-shell
  ./install.sh
  ```

Не забудьте установить графический драйвер так как Picom очень требовательный, если вы его еще не установили:
- nvidia

  ```
  yay -Sy --noconfirm nvidia
  ```
  или
  ```
  sudo pacman -Sy --noconfirm nvidia
  ```

- nvidia-open (новый, не советую использовать)

  ```
  yay -Sy --noconfirm nvidia-open
  ```

- Запустите из tty:

  ```
  eshell
  ```

<h2 align="center">Кейбинды</h2>

| Ключ                               | Действие                    |
| -----                              | -----                       |
| **Софт**                           | **Действие**                |
| Win + S                            | scrot                       |
| Win + Shift + S                    | scrot -s                    |
| Super + Tab                        | rofi                        |
| Super + W                          | firefox                     |
| Super + E                          | nemo                        |
| Super + Return                     | alacritty                   |
|                                    |                             |
| **Awesome**                        | **Действие**                |
| Super + Q                          | Закрыть фокусированное окно |
| Super + F                          | Фулл скрин                  |
| Super + N                          | Свернуть                    |
| Super + M                          | Фулл скрин (maximize)       |
| Super + Arrow [Up,Down,Left,Right] | Фокусирование на др. окно   |
