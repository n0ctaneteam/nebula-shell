local M = {}

M.schema = {
    id = { type = "string" },
    style_class = { type = "string", default = "box" },
    orientation = { type = "string", default = "horizontal", enum = {"horizontal", "vertical"} },
    spacing = { type = "number", default = 0 },
    anchor = { type = "any" },
    exclusive = { type = "boolean" },
    margin = { type = "table" },
    padding = { type = "table" },
    children = { type = "array", default = {} }
}

M.defaults = {
    style_class = "box",
    orientation = "horizontal",
    spacing = 0,
    margin = { all = 0 },
    padding = {all = 0}
}

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "box"
    config._orientation = config.orientation
    config._spacing = config.spacing
    config._children = config.children or {}

    if config.id then
        register_widget(config.id, config)
    end

    return config
end

function M.destroy(config)
    log_info("Box destroyed: " .. (config.id or "unknown"))
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
