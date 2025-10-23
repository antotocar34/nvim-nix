local catUtils = require('nixCatsUtils')

local diagnostics_controls = package.loaded['myLuaConf.diagnostics']
if not diagnostics_controls then
  local state = {
    diagnostics_enabled = true,
    warnings_enabled = true,
  }

  local attached_buffers = {}

  local function severity_filter()
    if state.warnings_enabled then
      return nil
    end
    return { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.ERROR }
  end

  local function for_each_attached_buffer(callback)
    for bufnr in pairs(attached_buffers) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        callback(bufnr)
      else
        attached_buffers[bufnr] = nil
      end
    end
  end

  local virtual_text_formatter

  local function build_config()
    local config = {
      severity_sort = true,
      update_in_insert = false,
      float = { border = 'rounded' },
      virtual_lines = false,
      severity = severity_filter(),
    }

    if state.diagnostics_enabled then
      config.signs = false
      config.underline = false
      config.virtual_text = {
        spacing = 0,
        prefix = '  ',
        format = virtual_text_formatter,
      }
    else
      config.signs = false
      config.underline = false
      config.virtual_text = false
    end

    return config
  end

  local function apply_config()
    local cfg = build_config()
    vim.diagnostic.config(cfg)
    for_each_attached_buffer(function(bufnr)
      if state.diagnostics_enabled then
        vim.diagnostic.hide(nil, bufnr)
        vim.diagnostic.show(nil, bufnr)
      else
        vim.diagnostic.hide(nil, bufnr)
      end
    end)
  end

  diagnostics_controls = {}

  function diagnostics_controls.current_severity()
    return severity_filter()
  end

  function diagnostics_controls.set_virtual_text_formatter(formatter)
    virtual_text_formatter = formatter
    apply_config()
  end

  function diagnostics_controls.apply_on_attach(bufnr)
    attached_buffers[bufnr] = true
    vim.api.nvim_create_autocmd('BufWipeout', {
      buffer = bufnr,
      callback = function()
        attached_buffers[bufnr] = nil
      end,
    })
    if state.diagnostics_enabled then
      vim.diagnostic.hide(nil, bufnr)
      vim.diagnostic.show(nil, bufnr)
    else
      vim.diagnostic.hide(nil, bufnr)
    end
  end

  function diagnostics_controls.should_refresh()
    return state.diagnostics_enabled
  end

  local function notify(message)
    vim.notify(message, vim.log.levels.INFO, { title = 'LSP Diagnostics' })
  end

  function diagnostics_controls.toggle_all()
    state.diagnostics_enabled = not state.diagnostics_enabled
    apply_config()
    -- notify(state.diagnostics_enabled and 'Diagnostics enabled' or 'Diagnostics disabled')
  end

  function diagnostics_controls.toggle_warnings()
    state.warnings_enabled = not state.warnings_enabled
    apply_config()
    -- TODO does not work
    -- notify(state.warnings_enabled and 'Warnings and hints enabled' or 'Warnings and hints hidden')
  end

  function diagnostics_controls.refresh()
    apply_config()
  end

  package.loaded['myLuaConf.diagnostics'] = diagnostics_controls
end
if (catUtils.isNixCats and nixCats('lspDebugMode')) then
  vim.lsp.set_log_level("debug")
end

local diagnostic_circle = vim.fn.nr2char(0x25CF)
local function diagnostic_text(diagnostic)
  local message = diagnostic.message or ''
  message = message:gsub('\n.*', '')
  if message == '' then
    return diagnostic_circle
  end
  return diagnostic_circle .. ' ' .. message
end
diagnostics_controls.set_virtual_text_formatter(diagnostic_text)
diagnostics_controls.refresh()

do
  local orig_open_floating_preview = vim.lsp.util.open_floating_preview
  vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or 'rounded'
    return orig_open_floating_preview(contents, syntax, opts, ...)
  end
end

local function dim_inlay_hints()
  pcall(vim.api.nvim_set_hl, 0, 'LspInlayHint', { link = 'Comment' })
end
dim_inlay_hints()
vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'Keep inlay hints subtle after colorscheme changes',
  callback = dim_inlay_hints,
})

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

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('myLuaConf.lsp.attach', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    require('myLuaConf.LSPs.on_attach')(client, args.buf)
  end,
})


local function convert_diagnostics(items)
  if not items then
    return {}
  end
  local converted = {}
  for _, diagnostic in ipairs(items) do
    local range = diagnostic.range or diagnostic.targetRange
    if range and range.start and type(range.start.line) == 'number' then
      local range_end = range['end']
      table.insert(converted, {
        lnum = range.start.line,
        col = range.start.character or 0,
        end_lnum = range_end and range_end.line or range.start.line,
        end_col = range_end and range_end.character or range.start.character or 0,
        severity = diagnostic.severity,
        message = diagnostic.message or '',
        source = diagnostic.source,
        code = diagnostic.code,
        user_data = diagnostic,
      })
    end
  end
  return converted
end


local refresh_group = vim.api.nvim_create_augroup('myLuaConf.lsp.refresh_diagnostics', { clear = true })
vim.api.nvim_create_autocmd({ 'InsertLeave', 'BufWritePost' }, {
  group = refresh_group,
  callback = function(args)
    local bufnr = args.buf
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    if not diagnostics_controls.should_refresh() then
      return
    end
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      -- Request a diagnostics refresh from clients that support the LSP 3.18 diagnostic pull API.
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if client.supports_method('textDocument/diagnostic') then
          local params = vim.lsp.util.make_text_document_params(bufnr)
          client:request('textDocument/diagnostic', { textDocument = params }, function(err, result)
            if err or not result then
              return
            end
            local namespace = vim.lsp.diagnostic.get_namespace(client.id)
            if result.kind ~= 'unchanged' then
              vim.diagnostic.set(namespace, bufnr, convert_diagnostics(result.items), {})
            end
            if result.relatedDocuments then
              for uri, doc in pairs(result.relatedDocuments) do
                if doc.kind ~= 'unchanged' then
                  local related_bufnr = vim.uri_to_bufnr(uri)
                  if related_bufnr and vim.api.nvim_buf_is_valid(related_bufnr) then
                    vim.diagnostic.set(namespace, related_bufnr, convert_diagnostics(doc.items), {})
                  end
                end
              end
            end
          end)
        end
      end
      vim.diagnostic.show(nil, bufnr)
    end)
  end,
})


require('lze').load {
  {
    "nvim-lspconfig",
    for_cat = "general.core",
    -- on_require = { "lspconfig" },
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
              expr = nixCats.extra("nixdExtras.nixos_options")
            },
            -- If you have your config as a separate flake, inputs.self would be referring to the wrong flake.
            -- You can override the correct one into your package definition on import in your main configuration,
            -- or just put an absolute path to where it usually is and accept the impurity.
            ["home-manager"] = {
              -- nixdExtras.home_manager_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").homeConfigurations.configname.options''
              expr = nixCats.extra("nixdExtras.home_manager_options")
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
