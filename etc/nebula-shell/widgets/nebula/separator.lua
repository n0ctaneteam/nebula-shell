local M = {}

M.schema = {
    id = { type = "string" },
    style_class = { type = "string", default = "separator" },
    orientation = { type = "string", default = "horizontal", enum = {"horizontal", "vertical"} }
}

M.defaults = {
    style_class = "separator",
    orientation = "horizontal"
}

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "separator"
    config._orientation = config.orientation

    if config.id then
        register_widget(config.id, config)
    end

    return config
end

function M.destroy(config)
    log_info("Separator destroyed: " .. (config.id or "unknown"))
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
