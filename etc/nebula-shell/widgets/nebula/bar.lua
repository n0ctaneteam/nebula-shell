local M = {}

M.schema = {
    id = { type = "string", required = true },
    style_class = { type = "string", default = "bar" },
    anchor = { type = "any", default = "top" },
    exclusive = { type = "boolean", default = true },
    height = { type = "number", default = 32 },
    size = { type = "any", default = "auto" },
    children = { type = "array", default = {} }
}

M.defaults = {
    style_class = "bar",
    anchor = "top",
    exclusive = true,
    height = 32,
    size = "auto"
}

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "window"
    config._window_type = "bar"
    config._layer = config.layer or "top"
    config._orientation = config.orientation or "horizontal"
    config._spacing = config.spacing or 0
    config._children = config.children or {}

    if config.id then
        register_widget(config.id, config)
    end

    return config
end

function M.destroy(config)
    log_info("Bar destroyed: " .. (config.id or "unknown"))
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
