-- Self-contained vim.tty shim for nvim 0.12.2 builds that ship a binary
-- expecting runtime/lua/vim/tty.lua but omit the file (and its vim._core.util
-- dependency). Implements the public API used by the compiled defaults:
--   request, query, query_apc, _get_termdefs
-- using only stable public nvim APIs so terminal capability detection still
-- works without the missing internal helper module.

local M = {}

local function on_termresponse(group, opts, callback)
  return vim.api.nvim_create_autocmd('TermResponse', {
    group = group,
    nested = true,
    callback = function(ev)
      local data = ev.data or {}
      if opts.chan and data.chan ~= opts.chan then
        return
      end
      return callback(data)
    end,
  })
end

--- Send `payload` and listen for TermResponse events, invoking on_response per
--- response. Auto-cleans after opts.timeout ms (default 1000; 0 = never).
function M.request(payload, opts, on_response)
  vim.validate('payload', payload, 'string')
  vim.validate('on_response', on_response, 'function')
  opts = opts or {}
  local timeout = opts.timeout or 1000

  local timer
  if timeout > 0 then
    timer = vim.uv and vim.uv.new_timer() or nil
  end

  local id = on_termresponse(opts.group, opts, function(data)
    local stop = on_response(data.sequence)
    if stop and timer and not timer:is_closing() then
      timer:close()
    end
    return stop
  end)

  if payload ~= '' then
    pcall(vim.api.nvim_ui_send, payload)
  end

  if timer then
    timer:start(timeout, 0, function()
      vim.schedule(function()
        pcall(vim.api.nvim_del_autocmd, id)
        if opts.on_timeout then
          opts.on_timeout()
        end
      end)
      if not timer:is_closing() then
        timer:close()
      end
    end)
  end

  return id
end

--- Query terminal capabilities via XTGETTCAP.
function M.query(caps, opts, on_response)
  if type(opts) == 'function' then
    on_response = opts
    opts = {}
  end
  opts = opts or {}
  if type(caps) ~= 'table' then
    caps = { caps }
  end

  local pending = {}
  for _, v in ipairs(caps) do
    pending[v] = true
  end

  local encoded = {}
  for i = 1, #caps do
    encoded[i] = vim.text.hexencode(caps[i])
  end
  local payload = ('\027P+q%s\027\\'):format(table.concat(encoded, ';'))

  M.request(payload, {
    timeout = opts.timeout,
    group = opts.group,
    chan = opts.chan,
    on_timeout = function()
      for k in pairs(pending) do
        on_response(k, false, nil)
      end
      if opts.on_timeout then
        opts.on_timeout()
      end
    end,
  }, function(resp)
    local k, rest = resp:match('^\027P1%+r(%x+)(.*)$')
    if not k or not rest then
      return
    end
    local cap = vim.text.hexdecode(k)
    if not cap or not pending[cap] then
      return
    end
    local seq
    if rest:match('^=%x+$') then
      seq = vim.text
        .hexdecode(rest:sub(2))
        :gsub('\\E', '\027')
        :gsub('%%p%d', '')
        :gsub('\\(%d+)', string.char)
    end
    on_response(cap, true, seq)
    pending[cap] = nil
    return next(pending) == nil
  end)
end

--- Send an APC sequence and invoke on_response for each APC TermResponse.
function M.query_apc(payload, opts, on_response)
  if type(opts) == 'function' then
    on_response = opts
    opts = {}
  end
  M.request(payload, opts, function(resp)
    if resp:match('^\027_') then
      return on_response(resp)
    end
  end)
end

--- Parse user terminfo overrides from $NVIM_TERMDEFS.
function M._get_termdefs()
  local raw = os.getenv('NVIM_TERMDEFS')
  if raw == nil then
    return nil
  end
  local ok, decoded = pcall(vim.json.decode, raw)
  if not ok or type(decoded) ~= 'table' or vim.isarray(decoded) then
    return nil
  end
  return decoded
end

return M
