
pcall(require, 'myLuaConf.shims')

-- NOTE: various, non-plugin config
require('myLuaConf.opts_and_keys')

require('myLuaConf.terminal_compat')

-- NOTE: register an extra lze handler with the spec_field 'for_cat'
-- that makes enabling an lze spec for a category slightly nicer
require("lze").register_handlers(require('nixCatsUtils.lzUtils').for_cat)

-- NOTE: Register another one from lzextras. This one makes it so that
-- you can set up lsps within lze specs,
-- and trigger lspconfig setup hooks only on the correct filetypes
require('lze').register_handlers(require('lzextras').lsp)
-- demonstrated in ./LSPs/init.lua

-- NOTE: general plugins
require("myLuaConf.plugins")

require("myLuaConf.LSPs")

if nixCats('debug') then
  require('myLuaConf.debug')
end

if nixCats('lint') then
  require('myLuaConf.lint')
end
if nixCats('format') then
  require('myLuaConf.format')
end
