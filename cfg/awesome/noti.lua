local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local noti = {}
local colors = {
    bg = "#1a1a1aDF",
    surface = "#2a2a2aCC",
    primary = "#ffffff",
    secondary = "#aaaaaa",
    accent = "#007AFF",
    border = "#40404088",
    shadow = "#00000060"
}
local config = {
    width = 300,
    margin = 20,
    spacing = 10,
    timeout = 3,
    animation_duration = 0.3
}

local notifications = {}
local current_notification = nil
function noti.show(title, message, timeout)
    local screen = awful.screen.focused()
    timeout = timeout or config.timeout
    local noti_wibox = wibox {
        screen = screen,
        width = config.width,
        height = 80,
        bg = colors.bg,
        border_width = 1,
        border_color = colors.border,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 12)
        end,
        ontop = true,
        visible = false,
        type = "notification"
    }

    local content = wibox.widget {
        {
            {
                {
                    {
                        markup = "<span foreground='" .. colors.primary .. "' weight='bold' size='large'>" .. (title or "Awedots") .. "</span>",
                        widget = wibox.widget.textbox
                    },
                    spacing = 8,
                    layout = wibox.layout.fixed.horizontal
                },
                {
                    markup = "<span foreground='" .. colors.secondary .. "' size='medium'>" .. (message or "Hello, World!") .. "</span>",
                    widget = wibox.widget.textbox
                },
                layout = wibox.layout.fixed.vertical,
                spacing = 5
            },
            margins = 16,
            widget = wibox.container.margin
        },
        bg = colors.surface,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 10)
        end,
        widget = wibox.container.background
    }

    noti_wibox:setup {
        content,
        widget = wibox.container.margin
    }

    local function update_position()
        local screen_geometry = screen.geometry
        local x, y
        x = (screen_geometry.width - config.width) / 2
        y = config.margin
        local dock_height = 76 + 20
        if config.position:find("top") then
            y = y + dock_height
        end
        noti_wibox.x = x
        noti_wibox.y = y
    end

    local function show_animation()
        update_position()
        local start_y = noti_wibox.y - 100
        noti_wibox.y = start_y
        noti_wibox.opacity = 0
        noti_wibox.visible = true
        local steps = 20
        local current_step = 0
        gears.timer.start_new(config.animation_duration / steps, function()
            current_step = current_step + 1
            local progress = current_step / steps
            local eased = 1 - math.pow(1 - progress, 3)
            noti_wibox.y = start_y + (config.margin + (config.position:find("top") and 76 + 20 or 0) - start_y) * eased
            noti_wibox.opacity = eased
            if current_step >= steps then
                noti_wibox.opacity = 1
                return false
            end
            return true
        end)
    end

    local function hide_animation(callback)
        local start_y = noti_wibox.y
        local end_y = start_y - 100
        local start_opacity = noti_wibox.opacity
        local steps = 15
        local current_step = 0
        gears.timer.start_new(config.animation_duration / steps, function()
            current_step = current_step + 1
            local progress = current_step / steps
            local eased = math.pow(progress, 3)
            noti_wibox.y = start_y + (end_y - start_y) * eased
            noti_wibox.opacity = start_opacity * (1 - eased)
            if current_step >= steps then
                noti_wibox.visible = false
                if callback then callback() end
                return false
            end
            return true
        end)
    end

    local notification = {
        wibox = noti_wibox,
        show = show_animation,
        hide = hide_animation,
        timeout = timeout
    }
    table.insert(notifications, notification)
    if not current_notification then
        noti.process_queue()
    end
    return notification
end

function noti.process_queue()
    if #notifications == 0 or current_notification then
        return
    end
    current_notification = table.remove(notifications, 1)
    current_notification.show()
    gears.timer.start_new(current_notification.timeout, function()
        if current_notification then
            current_notification.hide(function()
                current_notification.wibox:emit_signal("widget::redraw_needed")
                current_notification = nil
                gears.timer.start_new(0.5, function()
                    noti.process_queue()
                end)
            end)
        end
    end)
end

function noti.close_all()
    for _, notification in ipairs(notifications) do
        notification.wibox.visible = false
        notification.shadow.visible = false
    end
    notifications = {}
    if current_notification then
        current_notification.wibox.visible = false
        current_notification.shadow.visible = false
        current_notification = nil
    end
end

function noti.setup(user_config)
    config = gears.table.join(config, user_config or {})
end

return noti
