local M = {}

M.schema = {
    id = { type = "string" },
    style_class = { type = "string", default = "label" },
    text = { type = "string", default = "" }
}

M.defaults = {
    style_class = "label",
    text = ""
}

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "label"
    config._text = config.text

    if config.id then
        register_widget(config.id, config)
    end

    return config
end

function M.set_text(config, text)
    config._text = text
    widget_set_label(config.id, text)
end

function M.destroy(config)
    log_info("Label destroyed: " .. (config.id or "unknown"))
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
