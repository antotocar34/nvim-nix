-- Backward compatibility helpers for upstream API changes
local original_str_utfindex = vim.str_utfindex
if type(original_str_utfindex) ~= 'function' then
  return
end

---Provide legacy call pattern support for plugins still using the 0.11 API.
---@param str string
---@param encoding_or_index string|integer
---@param index_or_strict? integer|boolean
---@param strict_indexing? boolean
vim.str_utfindex = function(str, encoding_or_index, index_or_strict, strict_indexing)
  if type(encoding_or_index) ~= 'string' then
    local index = encoding_or_index
    local strict = index_or_strict
    return original_str_utfindex(str, vim.o.encoding, index, strict)
  end
  return original_str_utfindex(str, encoding_or_index, index_or_strict, strict_indexing)
end
