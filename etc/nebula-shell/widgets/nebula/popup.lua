local M = {}

M.schema = {
    id = { type = "string", required = true },
    style_class = { type = "string", default = "popup" },
    visible = { type = "boolean", default = false },
    size = { type = "any", default = "auto" },
    orientation = { type = "string", default = "horizontal", enum = {"horizontal", "vertical"} },
    spacing = { type = "number", default = 0 },
    autohide = { type = "number", default = 0 },
    showPointer = { type = "boolean", default = false },
    margin = { type = "table" },
    padding = { type = "table" },
    children = { type = "array", default = {} }
}

M.defaults = {
    style_class = "popup",
    visible = false,
    autohide = 0,
    showPointer = false,
    size = "auto",
    orientation = "horizontal",
    spacing = 0
}

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "popover"
    config._orientation = config.orientation
    config._spacing = config.spacing
    config._children = config.children or {}

    if config.id then
        register_widget(config.id, config)
    end

    return config
end

function M.show(config, parent_id)
    local parent = get_widget_by_id(parent_id)
    if parent == nil then
        log_error("Popup show: parent widget not found: " .. parent_id)
        return
    end
    widget_set_parent(config.id, parent)
    popup_widget(config.id)
end

function M.hide(config)
    widget_set_visible(config.id, false)
end

function M.destroy(config)
    log_info("Popover destroyed: " .. (config.id or "unknown"))
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
