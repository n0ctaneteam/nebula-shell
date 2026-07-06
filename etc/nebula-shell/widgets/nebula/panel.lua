local M = {}

M.schema = {
    id = { type = "string", required = true },
    style_class = { type = "string", default = "panel" },
    visible = { type = "boolean", default = false },
    anchor = { type = "string", default = "bottom", enum = {"top", "bottom"} },
    height = { type = "number", default = 300 },
    children = { type = "array", default = {} }
}

M.defaults = {
    style_class = "panel",
    visible = false,
    anchor = "bottom",
    height = 300
}

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "window"
    config._window_type = "panel"
    config._children = config.children or {}

    if config.id then
        register_widget(config.id, config)
    end

    return config
end

function M.toggle_visibility(config)
    local is_visible = widget_get_visible(config.id)
    widget_set_visible(config.id, not is_visible)
    return not is_visible
end

function M.destroy(config)
    log_info("Panel destroyed: " .. (config.id or "unknown"))
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
