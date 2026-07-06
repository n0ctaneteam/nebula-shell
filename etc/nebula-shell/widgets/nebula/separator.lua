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
        result[key] = props[key] or default
    end
    for key, value in pairs(props) do
        result[key] = value
    end
    return result
end

return M
