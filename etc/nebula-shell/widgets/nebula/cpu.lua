local M = {}

M.schema = {
    id = { type = "string" },
    style_class = { type = "string", default = "cpu-bar" },
    update_interval = { type = "number", default = 2 },
    warning_threshold = { type = "number", default = 70 },
    critical_threshold = { type = "number", default = 90 }
}

M.defaults = {
    style_class = "cpu-bar",
    update_interval = 2,
    warning_threshold = 70,
    critical_threshold = 90
}

local prev_idle = 0
local prev_total = 0

function M.create(props, event_handlers)
    local config = M.merge_defaults(props)
    config._type = "progress_bar"
    config._timer_enabled = true
    config._timer_interval = config.update_interval
    config._value = 0
    config._text = "0%"
    config._prev_idle = 0
    config._prev_total = 0

    M.read_cpu(config)

    if config.id then
        register_widget(config.id, config)
    end

    return config
end

function M.read_cpu(config)
    local f = io.open("/proc/stat", "r")
    if not f then
        config._text = "N/A"
        config._value = 0
        return
    end

    local line = f:read()
    f:close()

    if not line or line:sub(1, 4) ~= "cpu " then
        config._text = "N/A"
        config._value = 0
        return
    end

    local _, _, user, nice, system, idle, iowait, irq, softirq, steal =
        string.find(line, "cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")

    if not user then
        config._text = "N/A"
        config._value = 0
        return
    end

    user = tonumber(user)
    nice = tonumber(nice)
    system = tonumber(system)
    idle = tonumber(idle)
    iowait = tonumber(iowait)
    irq = tonumber(irq)
    softirq = tonumber(softirq)
    steal = tonumber(steal)

    local total = user + nice + system + idle + iowait + irq + softirq + steal
    local idle_all = idle + iowait

    if config._prev_total > 0 then
        local delta_total = total - config._prev_total
        local delta_idle = idle_all - config._prev_idle

        if delta_total > 0 then
            local usage = (delta_total - delta_idle) / delta_total * 100
            config._value = usage / 100
            config._text = string.format("%.0f%%", usage)

            widget_set_fraction(config.id, config._value)
            widget_set_text(config.id, config._text)

            if usage >= config.critical_threshold then
                widget_add_css_class(config.id, "critical")
                widget_remove_css_class(config.id, "warning")
            elseif usage >= config.warning_threshold then
                widget_add_css_class(config.id, "warning")
                widget_remove_css_class(config.id, "critical")
            else
                widget_remove_css_class(config.id, "warning")
                widget_remove_css_class(config.id, "critical")
            end
        end
    end

    config._prev_total = total
    config._prev_idle = idle_all
end

function M.destroy(config)
    config._timer_enabled = false
    log_info("CPU meter destroyed: " .. (config.id or "unknown"))
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
