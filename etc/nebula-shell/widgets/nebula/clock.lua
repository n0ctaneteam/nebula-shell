local M = {}

M.schema = {
    id = { type = "string" },
    style_class = { type = "string", default = "clock" },
    format = { type = "string", default = "%H:%M:%S" },
    interval = { type = "number", default = 1 },
    on_click = { type = "string" }
}

M.defaults = {
    style_class = "clock",
    format = "%H:%M:%S",
    interval = 1
}

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "label"
    config._timer_enabled = true
    config._timer_interval = config.interval
    config._format = config.format

    if config.on_click and event_handlers and event_handlers[config.on_click] then
        config._on_click = function()
            M.toggle_format(config)
            event_handlers[config.on_click](config)
        end
    end

    if config.id then
        register_widget(config.id, config)
    end

    return config
end

function M.update(config)
    local now = os.date(config._format or "%H:%M:%S")
    config._text = now

    widget_set_label(config.id, now)
end

function M.toggle_format(config)
    if config._format == "%H:%M:%S" then
        config._format = "%I:%M %p"
    else
        config._format = "%H:%M:%S"
    end
end

function M.destroy(config)
    config._timer_enabled = false
    log_info("Clock destroyed: " .. (config.id or "unknown"))
end

function M.merge_defaults(props)
    local result = {}
    for key, default in pairs(M.defaults) do
        result[key] = props[key] or default
    end
    for key, value in pairs(props) do
        result[key] = value
    end
    return result
end

return M
