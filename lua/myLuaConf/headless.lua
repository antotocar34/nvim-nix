local M = {}

local function collect_messages()
  local ok, result = pcall(vim.api.nvim_exec2, 'messages', { output = true })
  if not ok or result.output == '' then
    return {}
  end
  return vim.split(result.output, '\n', { plain = true, trimempty = true })
end

local function collect_notifications()
  local ok, notify = pcall(require, 'notify')
  if not ok or type(notify.history) ~= 'function' then
    return {}
  end

  local lines = {}
  for _, entry in ipairs(notify.history()) do
    local title = entry.title and table.concat(entry.title, ' ') or 'notify'
    local level = entry.level or 'INFO'
    table.insert(lines, string.format('[notify][%s] %s', level, title))
    for _, message_line in ipairs(entry.message or {}) do
      table.insert(lines, '  ' .. message_line)
    end
  end
  return lines
end

function M.dump()
  local output = {}

  local messages = collect_messages()
  if #messages > 0 then
    table.insert(output, '== messages ==')
    vim.list_extend(output, messages)
  end

  local errmsg = vim.api.nvim_get_vvar('errmsg')
  if type(errmsg) == 'string' and errmsg ~= '' then
    table.insert(output, '== v:errmsg ==')
    table.insert(output, errmsg)
  end

  local notifications = collect_notifications()
  if #notifications > 0 then
    table.insert(output, '== notifications ==')
    vim.list_extend(output, notifications)
  end

  if #output == 0 then
    output = { 'No messages, errors, or notifications recorded.' }
  end

  for _, line in ipairs(output) do
    vim.api.nvim_out_write(line .. '\n')
  end
end

return M
