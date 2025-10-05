#!/usr/bin/env bash
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
RESET='\033[0m'

function info() {
    echo -e "${CYAN}${BOLD}=>${RESET} $1"
}

function success() {
    echo -e "${GREEN}${BOLD}✓${RESET} $1"
}

function warn() {
    echo -e "${YELLOW}${BOLD}!${RESET} $1"
}

function error() {
    echo -e "${RED}${BOLD}x${RESET} $1" >&2
}

if ! command -v yay &>/dev/null; then
    info "Yay не найден, устанавливаю..."
    sudo pacman -Sy --needed --noconfirm git base-devel
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir"
    pushd "$tmpdir" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null
    rm -rf "$tmpdir"
    success "Yay установлен."
else
    success "Yay найден"
fi

if [[ -f ./pkgs.txt ]]; then
    info "Устанавливаю пакеты из pkgs.txt..."
    yay -S --needed --noconfirm $(< ./pkgs.txt)
    success "Основные пакеты установлены."
else
    warn "Файл pkgs.txt не найден, пропускаю установку пакетов."
fi
if [[ -d ./cfg ]]; then
    info "Копирую конфиги в ~/.config/..."
    mkdir -p ~/.config/
    cp -rfv ./cfg/* ~/.config/
    success "Конфиги установлены."
else
    warn "Папка cfg не найдена."
fi
if [[ -d ./scripts ]]; then
    info "Копирую скрипты в ~..."
    cp -rfv ./scripts/* ~/
    success "Скрипты установлены."
else
    warn "Папка scripts не найдена."
fi

success "Установка завершена!"
