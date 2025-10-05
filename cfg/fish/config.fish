if status is-interactive
    set fish_greeting
    starship init fish | source

    # Алиасы
    alias ysy "yay -Sy --noconfirm"
    alias psy "sudo pacman -Sy --noconfirm"
    alias yrns "yay -Rns --noconfirm"
    alias prns "sudo pacman -Rns --noconfirm"
    alias yss "yay -Ss"
    alias pss "pacman -Ss"
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
end
