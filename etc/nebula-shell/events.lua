-- /etc/nebula-shell/events.lua
-- Global event handlers for NebulaShell

-- Toggle panel visibility
function toggle_panel_visibility(source_widget)
    local panel_id = "main_panel"
    local is_visible = widget_get_visible(panel_id)
    widget_set_visible(panel_id, not is_visible)

    local toggle_btn = get_widget_by_id("toggle_panel_btn")
    if toggle_btn then
        if not is_visible then
            widget_set_label("toggle_panel_btn", "\u{2715}")
        else
            widget_set_label("toggle_panel_btn", "\u{2630}")
        end
    end

    log_info("Panel visibility toggled: " .. tostring(not is_visible))
end

-- Toggle clock format
function toggle_clock_format(source_widget)
    local clock_id = source_widget or "system_clock"
    local format = widget_get_label(clock_id)
    if format:find(":") then
        widget_set_label(clock_id, os.date("%I:%M %p"))
    else
        widget_set_label(clock_id, os.date("%H:%M:%S"))
    end
    log_info("Clock format toggled")
end

-- Show about dialog
function show_about_dialog(source_widget)
    log_info("NebulaShell v0.1.0 - Lightweight Wayland Widget Framework")
    log_info("License: Apache 2.0 - Owner: N0ctaneTeam")
end

-- Reload config
function reload_config(source_widget)
    log_info("Config reload requested (not yet implemented)")
end

-- Show quick menu popup anchored to the source button
function show_quick_menu(source_widget)
    local parent = get_widget_by_id(source_widget)
    if parent == nil then return end
    widget_set_parent("quick_menu", parent)
    popup_widget("quick_menu")
end

-- Quit application
function quit_application(source_widget)
    log_info("Quit requested")
    os.exit(0)
end
