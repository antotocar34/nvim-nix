-- myLuaConf/diagnostics.lua
local M = {}

local diagnostic_circle = vim.fn.nr2char(0x25CF)
local function diagnostic_text(diagnostic)
  local message = diagnostic.message or ''
  message = message:gsub('\n.*', '')
  if message == '' then
    return diagnostic_circle
  end
  return diagnostic_circle .. ' ' .. message
end


local state = {
  enabled = true,          -- master visibility
  show_warnings = true,    -- if false => only errors
  formatter = diagnostic_text
}

-- Compute severity filter (used by handlers & floats)
local function severity_filter()
  if state.show_warnings then return nil end
  return { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.ERROR }
end

-- Dynamic config: using functions lets Nvim re-resolve on render
-- (Opts keys may be functions returning per-call values). :contentReference[oaicite:2]{index=2}
local function apply_config()
  vim.diagnostic.config({
    -- Don’t underline/sign; use virtual text only when enabled
    underline        = false,
    signs            = false,
    virtual_lines    = false,
    float            = { border = 'rounded', source = 'if_many' },
    severity_sort    = true,

    -- Update while typing so toggles visibly apply in insert mode. :contentReference[oaicite:3]{index=3}
    update_in_insert = true,

    -- Handlers read current state each time they render:
    virtual_text = function(_, bufnr)
      if not state.enabled then return false end
      return {
        spacing = 0,
        prefix  = '  ',
        format  = state.formatter,
        severity = severity_filter(),
      }
    end,

    -- Global severity filter for other handlers (floats, etc.). :contentReference[oaicite:4]{index=4}
    severity = function() return severity_filter() end,
  })
end

local function for_loaded_bufs(fn)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then fn(b) end
  end
end

-- Re-render to ensure handler functions are re-evaluated
local function hard_refresh()
  if not state.enabled then
    vim.diagnostic.enable(false) -- all buffers, all namespaces. :contentReference[oaicite:5]{index=5}
    return
  end
  vim.diagnostic.enable(true)
  for_loaded_bufs(function(bufnr)
    -- Hide then show to force recompute with latest config. :contentReference[oaicite:6]{index=6}
    vim.diagnostic.hide(nil, bufnr)
    vim.diagnostic.show(nil, bufnr)
  end)
end

-- Public API
function M.current_severity() return severity_filter() end

function M.set_virtual_text_formatter(fn)
  state.formatter = fn
  apply_config()
  hard_refresh()
end

function M.apply_on_attach(bufnr)
  -- Ensure the just-attached buffer follows master visibility. :contentReference[oaicite:7]{index=7}
  vim.diagnostic.enable(state.enabled, nil, nil, bufnr)
  -- Force a render so the dynamic config takes effect immediately.
  if state.enabled then
    vim.diagnostic.hide(nil, bufnr)
    vim.diagnostic.show(nil, bufnr)
  else
    vim.diagnostic.hide(nil, bufnr)
  end
end

function M.should_refresh() return state.enabled end

function M.toggle_all()
  state.enabled = not state.enabled
  apply_config()
  hard_refresh()
end

function M.toggle_warnings()
  state.show_warnings = not state.show_warnings
  apply_config()
  hard_refresh()
end

function M.refresh()
  apply_config()
  hard_refresh()
end

-- One-time autocmds to keep things consistent as the session evolves.
do
  local grp = vim.api.nvim_create_augroup('myLuaConf.diagnostics', { clear = true })

  -- New LSP client attached: sync buffer with current policy. :contentReference[oaicite:8]{index=8}
  vim.api.nvim_create_autocmd('LspAttach', {
    group = grp,
    callback = function(args)
      local bufnr = args.buf
      M.apply_on_attach(bufnr)
    end,
  })

  -- Entering a buffer: reassert config (in case other plugins mutated it).
  vim.api.nvim_create_autocmd('BufEnter', {
    group = grp,
    callback = function()
      apply_config()
      -- Don’t spam resets; just ensure visibility matches.
      vim.diagnostic.enable(state.enabled)
    end,
  })

  -- When diagnostics change, some UIs cache; ensure our severity is respected. :contentReference[oaicite:9]{index=9}
  vim.api.nvim_create_autocmd('DiagnosticChanged', {
    group = grp,
    callback = function(args)
      if not state.enabled then return end
      -- Minimal nudge: show current buffer with the active severity filter.
      local bufnr = args.buf
      vim.diagnostic.hide(nil, bufnr)
      vim.diagnostic.show(nil, bufnr)
    end,
  })
end

return M
