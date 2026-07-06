local M = {}

M.schema = {
    id = { type = "string" },
    style_class = { type = "string", default = "button" },
    label = { type = "string", default = "Button" },
    on_click = { type = "string" }
}

M.defaults = {
    style_class = "button",
    label = "Button"
}

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "button"
    config._text = config.label

    if config.on_click and event_handlers and event_handlers[config.on_click] then
        config._on_click = event_handlers[config.on_click]
    end

    if config.id then
        register_widget(config.id, config)
    end

    return config
end

function M.set_label(config, label)
    config._text = label
    widget_set_label(config.id, label)
end

function M.destroy(config)
    log_info("Button destroyed: " .. (config.id or "unknown"))
end

function M.merge_defaults(props)
    local result = {}
    for key, default in pairs(M.defaults) do
        if props[key] ~= nil then
            result[key] = props[key]
        else
            result[key] = default
        end
    end
    for key, value in pairs(props) do
        result[key] = value
    end
    return result
end

return M
