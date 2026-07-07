local M = {}

M.schema = {
    id = { type = "string", required = true },
    style_class = { type = "string", default = "popup" },
    visible = { type = "boolean", default = true },
    anchor = { type = "any", default = "center" },
    exclusive = { type = "boolean", default = false },
    size = { type = "any", default = "auto" },
    overlay = { type = "table" },
    margin = { type = "table" },
    padding = { type = "table" },
    children = { type = "array", default = {} }
}

M.defaults = {
    style_class = "popup",
    visible = true,
    anchor = "center",
    exclusive = false,
    size = "auto",
    overlay = { intensity = 8 }
}

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "window"
    config._layer = "overlay"
    config._has_overlay = true
    config._children = config.children or {}

    if config.id then
        register_widget(config.id, config)
    end

    return config
end

function M.destroy(config)
    log_info("Popup destroyed: " .. (config.id or "unknown"))
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
