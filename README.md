<h1 align="center">Fave</h1>
<details>Это тестовые дотфайлы, созданные чтобы проверить мои умения. Но вы все равно можете использовать эти дотфайлы.</details>

<details>0.1.0</details>
<p align="center">
  <img src="previews/1.jpg">
</p>
<p align="center">
  <img src="previews/2.jpg">
</p>
<p align="center">
  <img src="previews/3.jpg">
</p>
<details>0.1.1</details>
<p align="center">
  <img src="previews/4.jpg">
</p>
<p align="center">
  <img src="previews/5.jpg">
</p>

<h2 align="center">Установка</h2>

- Клонируйте репозиторий:

  ```
  git clone https://github.com/ellerstell4r/fave
  ```

- Запустите скрипт установки:

  ```
  cd fave
  ./install.sh
  ```

Советую установить доп. пакеты так как они включают все, что может быть полезно для вас.
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
  faveshell
  ```

<h2 align="center">Кейбинды</h2>

| Ключ                               | Действие                    |
| -----                              | -----                       |
| **Софт**                           | **Действие**                |
| Print                              | flameshot                   |
| Shift+Print                        | Гуи flameshot               |
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
