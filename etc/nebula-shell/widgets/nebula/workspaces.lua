local M = {}

M.schema = {
    id = { type = "string" },
    style_class = { type = "string", default = "workspaces" },
    update_interval = { type = "number", default = 0.5 }
}

M.defaults = {
    style_class = "workspaces",
    update_interval = 0.5
}

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "box"
    config._children = {}
    config._timer_enabled = true
    config._timer_interval = config.update_interval
    config._workspace_buttons = {}
    config._active_workspace = 1
    config._orientation = "horizontal"
    config._spacing = 2

    M.refresh_workspaces(config)

    if config.id then
        register_widget(config.id, config)
    end

    return config
end

function M.refresh_workspaces(config)
    local workspaces = M.get_workspaces()
    local active = M.get_active_workspace()

    config._active_workspace = active
    config._children = {}

    for _, ws in ipairs(workspaces) do
        local is_active = (ws.id == active)
        local child = {
            _type = "button",
            id = config.id .. "_ws_" .. ws.id,
            style_class = "workspace-btn" .. (is_active and " active" or ""),
            label = tostring(ws.id),
            _text = tostring(ws.id),
            _on_click = function()
                M.switch_to_workspace(ws.id)
            end
        }
        table.insert(config._children, child)
    end
end

function M.get_workspaces()
    local workspaces = {}
    local handle = io.popen("hyprctl workspaces -j 2>/dev/null", "r")
    if not handle then
        for i = 1, 5 do
            table.insert(workspaces, { id = i })
        end
        return workspaces
    end

    local output = handle:read("*all")
    handle:close()

    if output and output ~= "" then
        local ok, result = pcall(function()
            local json = require("json")
            return json.decode(output)
        end)
        if ok and result then
            for _, ws in ipairs(result) do
                table.insert(workspaces, { id = ws.id, name = ws.name })
            end
        end
    end

    if #workspaces == 0 then
        for i = 1, 5 do
            table.insert(workspaces, { id = i })
        end
    end

    table.sort(workspaces, function(a, b) return a.id < b.id end)
    return workspaces
end

function M.get_active_workspace()
    local handle = io.popen("hyprctl activeworkspace -j 2>/dev/null", "r")
    if not handle then return 1 end

    local output = handle:read("*all")
    handle:close()

    if output and output ~= "" then
        local ok, result = pcall(function()
            local json = require("json")
            return json.decode(output)
        end)
        if ok and result and result.id then
            return result.id
        end
    end

    return 1
end

function M.switch_to_workspace(id)
    os.execute("hyprctl dispatch workspace " .. id)
end

function M.destroy(config)
    config._timer_enabled = false
    log_info("Workspaces destroyed: " .. (config.id or "unknown"))
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
