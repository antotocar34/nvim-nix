local catUtils = require('nixCatsUtils')

require("myLuaConf.LSPs.diagnostics")

local diagnostic_circle = vim.fn.nr2char(0x25CF)
local function diagnostic_text(diagnostic)
  local message = diagnostic.message or ''
  message = message:gsub('\n.*', '')
  if message == '' then
    return diagnostic_circle
  end
  return diagnostic_circle .. ' ' .. message
end

do
  local orig_open_floating_preview = vim.lsp.util.open_floating_preview
  vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or 'rounded'
    return orig_open_floating_preview(contents, syntax, opts, ...)
  end
end



if (catUtils.isNixCats and nixCats('lspDebugMode')) then
  vim.lsp.set_log_level("debug")
end
-- NOTE: This file uses lzextras.lsp handler https://github.com/BirdeeHub/lzextras?tab=readme-ov-file#lsp-handler
-- This is a slightly more performant fallback function
-- for when you don't provide a filetype to trigger on yourself.
-- nixCats gives us the paths, which is faster than searching the rtp!
local old_ft_fallback = require('lze').h.lsp.get_ft_fallback()
local function rust_root_dir(fname)
  local ok, util = pcall(require, 'lspconfig.util')
  if ok then
    local from_project = util.root_pattern('Cargo.toml', 'rust-project.json', '.git')(fname)
    return from_project or util.path.dirname(fname)
  end
  return vim.fs.dirname(fname)
end

local function prefer_nix_store_cmd(bin)
  local fallback
  local path = vim.env.PATH or ''
  for entry in string.gmatch(path, '([^:]+)') do
    local candidate = entry .. '/' .. bin
    if vim.fn.executable(candidate) == 1 then
      if string.find(entry, '/nix/store/', 1, true) then
        return candidate
      end
      fallback = fallback or candidate
    end
  end
  local exepath = vim.fn.exepath(bin)
  if exepath ~= '' then
    return exepath
  end
  return fallback or bin
end


vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('myLuaConf.lsp.attach', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    require('myLuaConf.LSPs.on_attach')(client, args.buf)
  end,
})


-- pcall(vim.api.nvim_set_hl, 0, 'LspInlayHint', { link = 'Comment' })
-- vim.api.nvim_create_autocmd('ColorScheme', {
--   desc = 'Keep inlay hints subtle after colorscheme changes',
--   callback = dim_inlay_hints,
-- })

require('lze').h.lsp.set_ft_fallback(function(name)
  local lspcfg = nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) or nixCats.pawsible({ "allPlugins", "start", "nvim-lspconfig" })
  if lspcfg then
    local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
    if not ok then
      ok, cfg = pcall(dofile, lspcfg .. "/lua/lspconfig/configs/" .. name .. ".lua")
    end
    return (ok and cfg or {}).filetypes or {}
  else
    return old_ft_fallback(name)
  end
end)

require('lze').load {
  {
    "nvim-lspconfig",
    for_cat = "general.core",
    on_require = { "lspconfig" },
    -- NOTE: define a function for lsp,
    -- and it will run for all specs with type(plugin.lsp) == table
    -- when their filetype trigger loads them
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function(_)
      vim.cmd.packadd("nvim-lspconfig")
      vim.lsp.config('*', {
        on_attach = require('myLuaConf.LSPs.on_attach'),
      })
    end,
  },
  {
    "mason.nvim",
    -- only run it when not on nix
    enabled = not catUtils.isNixCats,
    on_plugin = { "nvim-lspconfig" },
    load = function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd("mason-lspconfig.nvim")
      require('mason').setup()
      -- auto install will make it install servers when lspconfig is called on them.
      require('mason-lspconfig').setup { automatic_installation = true, }
    end,
  },
  {
    -- lazydev makes your lsp way better in your config without needing extra lsp configuration.
    "lazydev.nvim",
    for_cat = "neonixdev",
    cmd = { "LazyDev" },
    ft = "lua",
    after = function(_)
      require('lazydev').setup({
        library = {
          { words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. '/lua' },
        },
      })
    end,
  },
  {
    -- name of the lsp
    "lua_ls",
    enabled = nixCats('lua') or nixCats('neonixdev') or false,
    -- provide a table containing filetypes,
    -- and then whatever your functions defined in the function type specs expect.
    -- in our case, it just expects the normal lspconfig setup options,
    -- but with a default on_attach and capabilities
    lsp = {
      -- if you provide the filetypes it doesn't ask lspconfig for the filetypes
      filetypes = { 'lua' },
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          formatters = {
            ignoreComments = true,
          },
          signatureHelp = { enabled = true },
          diagnostics = {
            globals = { "nixCats", "vim", },
            disable = { 'missing-fields' },
          },
          telemetry = { enabled = false },
        },
      },
    },
    -- also these are regular specs and you can use before and after and all the other normal fields
  },
  {
    "gopls",
    for_cat = "go",
    -- if you don't provide the filetypes it asks lspconfig for them
    lsp = {
      filetypes = { "go", "gomod", "gowork", "gotmpl" },
    },
  },
  {
    "rust_analyzer",
    for_cat = "rust",
    ft = "rust",
    after = function()
      vim.cmd.packadd('nvim-lspconfig')
      local ok, lspconfig = pcall(require, 'lspconfig')
      if not ok then
        vim.notify('[nixCats] Failed to load lspconfig for rust_analyzer', vim.log.levels.ERROR)
        return
      end

      lspconfig.rust_analyzer.setup {
        cmd = { prefer_nix_store_cmd('rust-analyzer') },
        root_dir = rust_root_dir,
        settings = {
          ["rust-analyzer"] = {
            updates = { checkOnStartup = false },
            cargo = { allFeatures = true },
            rustfmt = { overrideCommand = { "rustfmt" } },
            diagnostics = { enable = true },
          },
        },
      }
    end,
  },
  {
    "pyright",
    for_cat = "python",
    lsp = {
      filetypes = { "python" },
    },
  },
  {
    "rnix",
    -- mason doesn't have nixd
    enabled = not catUtils.isNixCats,
    lsp = {
      filetypes = { "nix" },
    },
  },
  {
    "nil_ls",
    -- mason doesn't have nixd
    enabled = not catUtils.isNixCats,
    lsp = {
      filetypes = { "nix" },
    },
  },
  {
    "nixd",
    enabled = catUtils.isNixCats and (nixCats('nix') or nixCats('neonixdev')) or false,
    lsp = {
      filetypes = { "nix" },
      settings = {
        nixd = {
          -- nixd requires some configuration.
          -- luckily, the nixCats plugin is here to pass whatever we need!
          -- we passed this in via the `extra` table in our packageDefinitions
          -- for additional configuration options, refer to:
          -- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
          nixpkgs = {
            -- in the extras set of your package definition:
            -- nixdExtras.nixpkgs = ''import ${pkgs.path} {}''
            expr = nixCats.extra("nixdExtras.nixpkgs") or [[import <nixpkgs> {}]],
          },
          options = {
            -- If you integrated with your system flake,
            -- you should use inputs.self as the path to your system flake
            -- that way it will ALWAYS work, regardless
            -- of where your config actually was.
            nixos = {
              -- nixdExtras.nixos_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").nixosConfigurations.configname.options''
              expr = nixCats.extra("nixdExtras.nixos_options") or [[import <nixos>]]
            },
            -- If you have your config as a separate flake, inputs.self would be referring to the wrong flake.
            -- You can override the correct one into your package definition on import in your main configuration,
            -- or just put an absolute path to where it usually is and accept the impurity.
            ["home-manager"] = {
              -- nixdExtras.home_manager_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").homeConfigurations.configname.options''
              -- HACK: set nixpath to options? and then import that?
              -- HACK: use the select module???
              -- HACK: use the select module???
              expr = nixCats.extra("nixdExtras.home_manager_options")
              or [[
                  let
                    hostname = <hostname>;
                    flake = (builtins.getFlake "path:${toString ~/.config/dotfiles}");
                    options = flake.homeConfigurations.${toString <hostname>}.options;
                  in
                  options
                ]]
            }
          },
          formatting = {
            command = { "nixfmt" }
          },
          diagnostic = {
            suppress = {
              "sema-escaping-with"
            }
          }
        }
      },
    },
  },
}
