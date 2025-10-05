local gears = require("gears")
local awful = require("awful")

local config = {}
config.modkey = "Mod4"
config.altkey = "Mod1"
config.terminal = "alacritty"
config.browser = "firefox"
config.file_manager = "nemo"
config.keyboard_layouts = "us,ru"
config.tags = { "1" }
config.keys = {
    reload = { config.modkey, "Shift" },
    quit = { config.modkey, "Shift" },
    powermenu = { config.modkey },

    -- Приложения
    terminal = { config.modkey },
    browser = { config.modkey },
    file_manager = { config.modkey },
    launcher = { config.modkey },

    -- Управление окнами
    close = { config.modkey },
    fullscreen = { config.modkey },
    minimize = { config.modkey },
    maximize = { config.modkey },

    -- Навигация
    focus_left = { config.modkey },
    focus_right = { config.modkey },
    focus_up = { config.modkey },
    focus_down = { config.modkey },

    -- Скриншотер
    screenshot = { config.modkey },
    screenshot_area = { config.modkey, "Shift" },
}
config.theme = {
    font = "Inter 10",
    bg_normal = "#0a0a0a",
    bg_focus = "#1a1a1a",
    bg_urgent = "#ff4444",
    fg_normal = "#ffffff",
    fg_focus = "#ffffff",
    fg_urgent = "#ffffff",
    border_normal = "#303030",
    border_focus = "#b5b5b5",
    border_marked = "#888888",
}
config.autostart = {
    "nm-applet",
    "blueman-applet",
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
    "rofi -show drun"
}

return config
