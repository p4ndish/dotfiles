-- PandaVim Utility Functions
-- Safe require and other helper functions for error handling

local M = {}

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

--- Safely require a module, returning nil if not available
-- @param modname string: Module name to require
-- @return table|nil: The module or nil if not available
function M.safe_require(modname)
    local ok, result = pcall(require, modname)
    if not ok then
        vim.notify(string.format("Module '%s' not available: %s", modname, result), vim.log.levels.DEBUG)
        return nil
    end
    return result
end

--- Check if a command exists in PATH
-- @param cmd string: Command to check
-- @return boolean: true if command exists
function M.cmd_exists(cmd)
    local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
    if not handle then
        return false
    end
    local result = handle:read("*a")
    handle:close()
    return result and trim(result) ~= ""
end

--- Get Mason binary path with system fallback
-- @param name string: Binary name in Mason
-- @return string|nil: Full path or nil if not found
function M.get_mason_bin(name)
    local mason_path = vim.fn.stdpath('data') .. '/mason/bin/' .. name
    if vim.fn.filereadable(mason_path) == 1 then
        return mason_path
    end
    -- Fallback to system binary
    if M.cmd_exists(name) then
        return name
    end
    return nil
end

--- Check if clipboard tool is available
-- @return boolean: true if clipboard is usable
function M.has_clipboard()
    -- macOS has built-in clipboard support
    if vim.fn.has('mac') == 1 then
        return true
    end
    -- Linux requires xclip or xsel
    local handle = io.popen("command -v xclip xsel 2>/dev/null")
    if handle then
        local result = handle:read("*a")
        handle:close()
        return result and trim(result) ~= ""
    end
    return false
end

--- Setup colorscheme with fallback
-- @param name string: Colorscheme name
-- @param fallback string|nil: Fallback colorscheme (default: "habamax")
function M.safe_colorscheme(name, fallback)
    fallback = fallback or "habamax"
    
    local ok, _ = pcall(vim.cmd, "colorscheme " .. name)
    if not ok then
        vim.notify(string.format("Colorscheme '%s' not available, using '%s'", name, fallback), vim.log.levels.WARN)
        pcall(vim.cmd, "colorscheme " .. fallback)
    end
end

return M
