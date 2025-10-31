return {
  "bqls",
  for_cat = 'bquery',
  ft = {'sql', 'bqsl'},
  on_plugin = "lspconfig",
  before = function()
    vim.filetype.add({ extension = {bqsql = "sql"} })
  end,
  after = function()
    -- now that configs.bqls exists, declare the lsp setup
    require("lspconfig").bqls.setup({
      settings = {
        project_id = "king-antoine-carnec-dev",
        location = "EU",
      }
    })
  end,
}
