local M = {}

M.schema = {
    id = { type = "string", required = true },
    style_class = { type = "string", default = "dialog" },
    visible = { type = "boolean", default = true },
    blockInput = { type = "boolean", default = true },
    size = { type = "any", default = "auto" },
    margin = { type = "table" },
    padding = { type = "table" },
    title = { type = "string", default = "" },
    content = { type = "string", default = "" },
    buttons = { type = "table", default = {} }
}

M.defaults = {
    style_class = "dialog",
    visible = true,
    blockInput = true,
    size = "auto",
    title = "",
    content = "",
    buttons = {}
}

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "dialog"
    config._layer = config.layer or "overlay"

    return config
end

function M.destroy(config)
    log_info("Dialog destroyed: " .. (config.id or "unknown"))
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
