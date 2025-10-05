local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local dock = {}
local colors = {
    bg = "#1a1a1a",
    surface = "#1a1a1a",
    surface_hover = "#2a2a2a",
    surface_active = "#2a2a2a",
    primary = "#ffffff",
    on_surface = "#ffffff",
    indicator_active = "#ffffff",
}

local function get_client_icon(c)
    if c and c.valid and c.icon then
        return c.icon
    end
    return nil
end

local function animate_property(widget, property, target, duration, callback)
    local start = widget[property]
    local steps = duration * 60
    local current_step = 0

    gears.timer.start_new(1 / 60, function()
        current_step = current_step + 1
        local progress = current_step / steps
        local eased = 1 - math.pow(1 - progress, 3)

        widget[property] = start + (target - start) * eased

        if current_step >= steps then
            widget[property] = target
            if callback then callback() end
            return false
        end
        return true
    end)
end

local function create_app_widget(c, dock_widget, dock_wibox)
    local icon_widget
    local icon = get_client_icon(c)

    if icon then
        icon_widget = wibox.widget {
            {
                image = icon,
                resize = true,
                forced_width = 44,
                forced_height = 44,
                widget = wibox.widget.imagebox
            },
            margins = 8,
            widget = wibox.container.margin
        }
    else
        icon_widget = wibox.widget {
            {
                {
                    markup = "<span foreground='" .. colors.on_surface .. "' size='x-large'>◆</span>",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox
                },
                forced_width = 44,
                forced_height = 44,
                widget = wibox.container.place
            },
            margins = 8,
            widget = wibox.container.margin
        }
    end

    local is_active = c == client.focus

    local indicator = wibox.widget {
        {
            bg = colors.indicator_active,
            shape = function(cr, w, h)
                gears.shape.rounded_rect(cr, w, h, 2)
            end,
            forced_height = is_active and 3 or 0,
            forced_width = 44,
            opacity = is_active and 1 or 0,
            widget = wibox.container.background
        },
        margins = { left = 8, right = 8, bottom = 6 },
        widget = wibox.container.margin
    }

    local icon_scale = wibox.widget {
        {
            icon_widget,
            widget = wibox.container.place
        },
        forced_width = 60,
        forced_height = 60,
        widget = wibox.container.constraint
    }

    local container = wibox.widget {
        {
            {
                icon_scale,
                indicator,
                layout = wibox.layout.fixed.vertical
            },
            bg = is_active and colors.surface_active or colors.surface,
            shape = function(cr, w, h)
                gears.shape.rounded_rect(cr, w, h, 18)
            end,
            widget = wibox.container.background
        },
        margins = 4,
        widget = wibox.container.margin
    }

    local hover_active = false
    local scale_timer = nil

    container:connect_signal("mouse::enter", function()
        hover_active = true
        container.children[1].bg = colors.surface_hover

        if scale_timer then scale_timer:stop() end

        local steps = 15
        local current_step = 0
        local start_margin = icon_scale.children[1].top or 0
        local target_margin = -8

        scale_timer = gears.timer.start_new(1 / 60, function()
            current_step = current_step + 1
            local progress = current_step / steps
            local eased = 1 - math.pow(1 - progress, 4)

            local margin = start_margin + (target_margin - start_margin) * eased
            icon_scale.children[1].top = margin
            icon_scale.children[1].bottom = margin
            icon_scale.children[1].left = margin
            icon_scale.children[1].right = margin

            if current_step >= steps then
                return false
            end
            return true
        end)
    end)

    container:connect_signal("mouse::leave", function()
        hover_active = false
        local current_active = (c == client.focus)
        container.children[1].bg = current_active and colors.surface_active or colors.surface

        if scale_timer then scale_timer:stop() end

        local steps = 15
        local current_step = 0
        local start_margin = icon_scale.children[1].top or -8
        local target_margin = 0

        scale_timer = gears.timer.start_new(1 / 60, function()
            current_step = current_step + 1
            local progress = current_step / steps
            local eased = 1 - math.pow(1 - progress, 3)

            local margin = start_margin + (target_margin - start_margin) * eased
            icon_scale.children[1].top = margin
            icon_scale.children[1].bottom = margin
            icon_scale.children[1].left = margin
            icon_scale.children[1].right = margin

            if current_step >= steps then
                return false
            end
            return true
        end)
    end)

    container:buttons(gears.table.join(
        awful.button({}, 1, function()
            if c and c.valid then
                if c.minimized then
                    c.minimized = false
                end
                c:emit_signal("request::activate", "dock", { raise = true })
            end
        end),
        awful.button({}, 3, function()
            if c and c.valid then
                local steps = 10
                local current_step = 0

                gears.timer.start_new(1 / 60, function()
                    current_step = current_step + 1
                    local progress = current_step / steps

                    container.opacity = 1 - progress

                    if current_step >= steps then
                        c:kill()
                        return false
                    end
                    return true
                end)
            end
        end)
    ))

    local function update_indicator()
        local is_focused = (c == client.focus)
        local target_height = is_focused and 3 or 0
        local target_opacity = is_focused and 1 or 0

        if not hover_active then
            container.children[1].bg = is_focused and colors.surface_active or colors.surface
        end

        local steps = 12
        local current_step = 0
        local start_height = indicator.children[1].forced_height
        local start_opacity = indicator.children[1].opacity

        gears.timer.start_new(1 / 60, function()
            current_step = current_step + 1
            local progress = current_step / steps
            local eased = 1 - math.pow(1 - progress, 3)

            indicator.children[1].forced_height = start_height + (target_height - start_height) * eased
            indicator.children[1].opacity = start_opacity + (target_opacity - start_opacity) * eased

            if current_step >= steps then
                return false
            end
            return true
        end)
    end

    c:connect_signal("focus", update_indicator)
    c:connect_signal("unfocus", update_indicator)

    return container
end

function dock.update(dock_widget, dock_wibox)
    if not dock_widget or not dock_wibox then return end

    local valid_clients = {}
    for _, c in ipairs(client.get()) do
        if c and c.valid and not c.skip_taskbar and not c.hidden then
            table.insert(valid_clients, c)
        end
    end

    if #valid_clients == 0 then
        local screen_height = dock_wibox.screen.geometry.height
        local target_y = screen_height + 100
        local steps = 25
        local current_step = 0
        local start_y = dock_wibox.y
        local start_opacity = dock_wibox.opacity

        gears.timer.start_new(1 / 60, function()
            current_step = current_step + 1
            local progress = current_step / steps
            local eased = 1 - math.pow(1 - progress, 2)

            dock_wibox.y = start_y + (target_y - start_y) * eased
            dock_wibox.opacity = start_opacity * (1 - progress)

            if current_step >= steps then
                dock_wibox.visible = false
                dock_wibox.opacity = 0
                return false
            end
            return true
        end)
        return
    end

    table.sort(valid_clients, function(a, b)
        if a and b and a.valid and b.valid then
            return a.window < b.window
        end
        return false
    end)

    local widgets_list = {}
    for _, c in ipairs(valid_clients) do
        if c and c.valid then
            table.insert(widgets_list, create_app_widget(c, dock_widget, dock_wibox))
        end
    end

    dock_widget:reset()
    dock_widget:setup {
        layout = wibox.layout.fixed.horizontal,
        spacing = 0,
        table.unpack(widgets_list)
    }

    local count = #widgets_list
    local new_width = count * 68 + 16
    new_width = math.max(84, new_width)

    local screen_geometry = dock_wibox.screen.geometry
    local final_x = (screen_geometry.width - new_width) / 2
    local final_y = screen_geometry.height - dock_wibox.height - 20

    if not dock_wibox.visible then
        dock_wibox.visible = true
        dock_wibox.width = new_width
        dock_wibox.x = final_x
        dock_wibox.y = screen_geometry.height + 100
        dock_wibox.opacity = 0

        local steps = 30
        local current_step = 0
        local start_y = dock_wibox.y

        gears.timer.start_new(1 / 60, function()
            current_step = current_step + 1
            local progress = current_step / steps
            local eased = 1 - math.pow(1 - progress, 4)

            dock_wibox.y = start_y + (final_y - start_y) * eased
            dock_wibox.opacity = progress

            if current_step >= steps then
                dock_wibox.y = final_y
                dock_wibox.opacity = 1
                return false
            end
            return true
        end)
    else
        local old_width = dock_wibox.width
        if math.abs(new_width - old_width) > 1 then
            local steps = 20
            local current_step = 0
            local old_x = dock_wibox.x

            gears.timer.start_new(1 / 60, function()
                current_step = current_step + 1
                local progress = current_step / steps
                local eased = 1 - math.pow(1 - progress, 3)

                dock_wibox.width = old_width + (new_width - old_width) * eased
                dock_wibox.x = old_x + (final_x - old_x) * eased

                if current_step >= steps then
                    dock_wibox.width = new_width
                    dock_wibox.x = final_x
                    return false
                end
                return true
            end)
        else
            dock_wibox.width = new_width
            dock_wibox.x = final_x
        end
        dock_wibox.y = final_y
    end
end

function dock.create(s)
    local dock_widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = 0
    }

    local dock_wibox = wibox {
        screen = s,
        width = 1,
        height = 84,
        bg = colors.bg,
        shape = function(cr, w, h)
            gears.shape.rectangle(cr, w, h)
        end,
        ontop = true,
        visible = false,
        type = "dock"
    }

    dock_wibox:setup {
        dock_widget,
        margins = 10,
        widget = wibox.container.margin
    }

    dock.update(dock_widget, dock_wibox)

    client.connect_signal("manage", function(c)
        gears.timer.delayed_call(function()
            dock.update(dock_widget, dock_wibox)
        end)
    end)

    client.connect_signal("unmanage", function(c)
        dock.update(dock_widget, dock_wibox)
    end)

    client.connect_signal("property::minimized", function(c)
        dock.update(dock_widget, dock_wibox)
    end)

    client.connect_signal("property::hidden", function(c)
        dock.update(dock_widget, dock_wibox)
    end)

    client.connect_signal("focus", function(c)
        dock.update(dock_widget, dock_wibox)
    end)

    client.connect_signal("unfocus", function(c)
        dock.update(dock_widget, dock_wibox)
    end)

    return dock_wibox
end

return dock
