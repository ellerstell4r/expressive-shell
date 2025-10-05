pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local config = require("config")
local dock = require("dock")
local noti = require("noti")

if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Ошибки при запуске!",
        text = awesome.startup_errors
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Ошибка!",
            text = tostring(err)
        })
        in_error = false
    end)
end

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.font = config.theme.font
beautiful.bg_normal = config.theme.bg_normal
beautiful.bg_focus = config.theme.bg_focus
beautiful.bg_urgent = config.theme.bg_urgent
beautiful.fg_normal = config.theme.fg_normal
beautiful.fg_focus = config.theme.fg_focus
beautiful.fg_urgent = config.theme.fg_urgent
beautiful.border_width = 1
beautiful.border_normal = config.theme.border_normal
beautiful.border_focus = config.theme.border_focus
beautiful.border_marked = config.theme.border_marked
beautiful.useless_gap = config.theme.useless_gap
awful.spawn.with_shell("setxkbmap -layout '" .. config.keyboard_layouts .. "' -option 'grp:alt_shift_toggle'")
awful.screen.connect_for_each_screen(function(s)
    awful.tag(config.tags, s, awful.layout.suit.floating)
    dock.create(s)
end)

local globalkeys = gears.table.join(
-- Управление
    awful.key(config.keys.reload, "r", awesome.restart,
        { description = "перезагрузить awesome", group = "awesome" }),
    awful.key(config.keys.quit, "q", awesome.quit,
        { description = "выйти из awesome", group = "awesome" }),
    awful.key(config.keys.powermenu, "p", function()
        awful.spawn(os.getenv("HOME") .. "/.config/rofi/powermenu.sh")
    end, { description = "открыть power menu", group = "приложения" }),

    -- Приложения
    awful.key(config.keys.terminal, "Return", function() awful.spawn(config.terminal) end,
        { description = "открыть терминал", group = "приложения" }),
    awful.key(config.keys.browser, "w", function() awful.spawn(config.browser) end,
        { description = "открыть браузер", group = "приложения" }),
    awful.key(config.keys.file_manager, "e", function() awful.spawn(config.file_manager) end,
        { description = "открыть файловый менеджер", group = "приложения" }),
    awful.key(config.keys.launcher, "Tab", function() awful.spawn("rofi -show drun") end,
        { description = "открыть лаунчер", group = "приложения" }),

    -- Навигация между окнами
    awful.key(config.keys.focus_left, "Left", function() awful.client.focus.bydirection("left") end,
        { description = "фокус влево", group = "окна" }),
    awful.key(config.keys.focus_right, "Right", function() awful.client.focus.bydirection("right") end,
        { description = "фокус вправо", group = "окна" }),
    awful.key(config.keys.focus_up, "Up", function() awful.client.focus.bydirection("up") end,
        { description = "фокус вверх", group = "окна" }),
    awful.key(config.keys.focus_down, "Down", function() awful.client.focus.bydirection("down") end,
        { description = "фокус вниз", group = "окна" }),

    -- Медиа
    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
    end, { description = "увеличить громкость", group = "медиа" }),

    awful.key({}, "XF86AudioLowerVolume", function()
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
    end, { description = "уменьшить громкость", group = "медиа" }),

    awful.key({}, "XF86AudioMute", function()
        awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    end, { description = "выключить звук", group = "медиа" }),

    -- Яркость
    awful.key({}, "XF86MonBrightnessUp", function()
        awful.spawn("brightnessctl set +10%")
    end, { description = "увеличить яркость", group = "система" }),

    awful.key({}, "XF86MonBrightnessDown", function()
        awful.spawn("brightnessctl set 10%-")
    end, { description = "уменьшить яркость", group = "система" }),

    -- Скриншоты
    awful.key(config.keys.screenshot, "s", function()
        awful.spawn("sh -c 'scrot -o -z /tmp/screen.png && xclip -selection clipboard -t image/png -i /tmp/screen.png'")
    end, { description = "скриншот всего экрана", group = "скриншоты" }),
    awful.key(config.keys.screenshot_area, "s", function()
        awful.spawn(
            "sh -c 'scrot -o -s -z /tmp/screen.png && xclip -selection clipboard -t image/png -i /tmp/screen.png'")
    end, { description = "скриншот области", group = "скриншоты" })
)

local clientkeys = gears.table.join(
    awful.key(config.keys.close, "q", function(c) c:kill() end,
        { description = "закрыть окно", group = "окна" }),
    awful.key(config.keys.fullscreen, "f", function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
        gears.timer.start_new(0.05, function()
            local g = c:geometry()
            c:geometry({ width = g.width + 1 })
            gears.timer.start_new(0.01, function()
                c:geometry({ width = g.width })
                return false
            end)
            return false
        end)
    end, { description = "полноэкранный режим", group = "окна" }),
    awful.key(config.keys.minimize, "n", function(c)
        c.minimized = true
    end, { description = "минимизировать", group = "окна" }),
    awful.key(config.keys.maximize, "m", function(c)
        c.maximized = not c.maximized
        c:raise()
        gears.timer.start_new(0.05, function()
            local g = c:geometry()
            c:geometry({ width = g.width + 1 })
            gears.timer.start_new(0.01, function()
                c:geometry({ width = g.width })
                return false
            end)
            return false
        end)
    end, { description = "максимизировать", group = "окна" })
)

local clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ config.modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        local old_coords = mouse.coords()
        awful.mouse.client.move(c)
        local new_coords = mouse.coords()
        c:emit_signal("property::geometry")
    end),
    awful.button({ config.modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
        c:emit_signal("property::geometry")
    end)
)

root.keys(globalkeys)
awful.rules.rules = {
    {
        rule = {},
        properties = {
            border_width = 0,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.centered,
            floating = true,
            useless_gap = 8
        }
    }
}
client.connect_signal("manage", function(c)
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
    if c.floating or awful.layout.get(c.screen) == awful.layout.suit.floating then
        awful.placement.centered(c)
    end
    c.border_color = config.theme.border_normal
end)
client.connect_signal("focus", function(c)
    c.border_color = config.theme.border_focus
end)
client.connect_signal("unfocus", function(c)
    c.border_color = config.theme.border_normal
end)
for _, cmd in ipairs(config.autostart) do
    awful.spawn.with_shell(cmd)
end
local wallpaper_path = os.getenv("HOME") .. "/.config/shell/wallpaper.jpg"
awful.spawn.with_shell("feh --bg-fill " .. wallpaper_path)
