local yaml = {}

function yaml.parse_file(path)
    local f, err = io.open(path, "r")
    if not f then
        error("Cannot open file: " .. path .. " (" .. tostring(err) .. ")")
        return nil
    end

    local content = f:read("*all")
    f:close()
    return yaml.parse(content)
end

function yaml.parse(content)
    local lines = {}
    for line in content:gmatch("[^\r\n]+") do
        local stripped = line:match("^%s*(.-)%s*$")
        if stripped ~= "" and stripped:sub(1, 1) ~= "#" then
            table.insert(lines, line)
        end
    end
    return yaml.parse_lines(lines, 1, #lines)
end

function yaml.parse_lines(lines, start_idx, end_idx)
    local result = {}
    local i = start_idx
    local current_key = nil
    local current_indent = nil

    while i <= end_idx do
        local line = lines[i]
        if line == nil then
            i = i + 1
            goto continue
        end

        local line_stripped = line:match("^%s*(.-)%s*$")
        if line_stripped == "" or line_stripped:sub(1, 1) == "#" then
            i = i + 1
            goto continue
        end

        local indent = line:match("^(%s*)")
        local indent_level = #indent

        if current_indent == nil then
            current_indent = indent_level
        end

        if indent_level < current_indent then
            return result, i
        end

        local list_item = line:match("^%s*%-%s+(.*)")
        if list_item then
            local items = {}
            local pending_key = nil

            -- Check if first item is a bare key (e.g. "nebula/workspaces:")
            local first_is_key = list_item:match("^[%w_/]+:$")
            if first_is_key then
                pending_key = list_item:match("^([%w_/]+):")
            else
                table.insert(items, yaml.parse_value(list_item))
            end
            i = i + 1

            while i <= end_idx do
                local next_line = lines[i]
                if next_line == nil then
                    i = i + 1
                    goto inner_continue
                end
                local next_stripped = next_line:match("^%s*(.-)%s*$")
                if next_stripped == "" or next_stripped:sub(1, 1) == "#" then
                    i = i + 1
                    goto inner_continue
                end

                local next_indent = #(next_line:match("^(%s*)"))
                if next_indent <= indent_level then
                    break
                end

                local next_item = next_line:match("^%s*%-%s+(.*)")
                if next_item then
                    -- Another list item at the same level
                    local val = yaml.parse_value(next_item)
                    if type(val) == "string" and next_item:match("^[%w_/]+:") then
                        local sub_key, sub_val = yaml.parse_kv(next_item)
                        local sub_table = {}
                        sub_table[sub_key] = sub_val
                        table.insert(items, sub_table)
                    else
                        table.insert(items, val)
                    end
                    i = i + 1
                else
                    -- Sub-properties block - merge into pending_key or add as flat
                    local rest, next_i = yaml.parse_lines(lines, i, end_idx)
                    if rest and next(rest) then
                        if pending_key then
                            local merged = {}
                            merged[pending_key] = rest
                            table.insert(items, merged)
                            pending_key = nil
                        else
                            table.insert(items, rest)
                        end
                    elseif pending_key then
                        local merged = {}
                        merged[pending_key] = {}
                        table.insert(items, merged)
                        pending_key = nil
                    end
                    i = next_i
                    break
                end
                    ::inner_continue::
            end

            -- Flush last pending_key if inner loop ended without sub-props
            if pending_key then
                local merged = {}
                merged[pending_key] = {}
                table.insert(items, merged)
                pending_key = nil
            end

            if #items > 0 then
                table.insert(result, items[1])
                for j = 2, #items do
                    table.insert(result, items[j])
                end
            end

            if current_key then
                result[current_key] = items
                current_key = nil
            end

            goto continue
        end

        local colon_pos = line:find(":", indent_level + 1, true)
        if colon_pos then
            local key = line:sub(indent_level + 1, colon_pos - 1)
            key = key:match("^%s*(.-)%s*$")

            local value_part = line:sub(colon_pos + 1)
            value_part = value_part:match("^%s*(.-)%s*$")

            if value_part == "" or value_part == nil then
                local sub_table, next_i = yaml.parse_lines(lines, i + 1, end_idx)
                result[key] = sub_table or {}
                i = next_i
            else
                result[key] = yaml.parse_value(value_part)
                i = i + 1
            end
        end

        ::continue::
    end

    return result, end_idx + 1
end

function yaml.parse_value(val)
    if val == "~" or val == "null" then
        return nil
    end
    if val == "true" or val == "yes" then
        return true
    end
    if val == "false" or val == "no" then
        return false
    end

    local num = tonumber(val)
    if num then
        return num
    end

    if val:sub(1, 1) == '"' and val:sub(-1) == '"' then
        local s = val:sub(2, -2)
        s = yaml.unescape_unicode(s)
        return s
    end
    if val:sub(1, 1) == "'" and val:sub(-1) == "'" then
        return val:sub(2, -2)
    end

    return val
end

-- Unicode code point to UTF-8 (works in Lua 5.2, 5.3, 5.4)
local function utf8_char(cp)
    if utf8 and utf8.char then
        return utf8.char(cp)
    end
    -- Lua 5.2 fallback: manual UTF-8 encoding
    if cp < 0x80 then
        return string.char(cp)
    elseif cp < 0x800 then
        return string.char(0xC0 + (cp >> 6), 0x80 + (cp & 0x3F))
    elseif cp < 0x10000 then
        return string.char(0xE0 + (cp >> 12), 0x80 + ((cp >> 6) & 0x3F), 0x80 + (cp & 0x3F))
    elseif cp < 0x110000 then
        return string.char(0xF0 + (cp >> 18), 0x80 + ((cp >> 12) & 0x3F), 0x80 + ((cp >> 6) & 0x3F), 0x80 + (cp & 0x3F))
    end
    return "?"
end

function yaml.unescape_unicode(s)
    -- \u{XXXXXX} (YAML 1.2 style)
    -- Note: braces are literal in Lua patterns, no escaping needed
    s = s:gsub("\\u{([0-9a-fA-F]+)}", function(hex)
        return utf8_char(tonumber(hex, 16))
    end)
    -- \uXXXX (YAML 1.1 4-digit style)
    s = s:gsub("\\u([0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])", function(hex)
        return utf8_char(tonumber(hex, 16))
    end)
    return s
end

function yaml.parse_kv(str)
    local colon = str:find(":")
    if not colon then return nil, str end
    local key = str:sub(1, colon - 1):match("^%s*(.-)%s*$")
    if key == "" then return nil, str end
    local val_str = str:sub(colon + 1):match("^%s*(.-)%s*$")
    if val_str == "" then
        return key, {}  -- empty table for sub-properties that follow
    end
    return key, yaml.parse_value(val_str)
end

function yaml_parse_file(path)
    return yaml.parse_file(path)
end

return yaml
