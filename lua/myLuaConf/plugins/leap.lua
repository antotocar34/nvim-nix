{
  "leap.nvim",
  for_cat = 'general.extra',
  event = "DeferredUIEnter",
  after = function(plugin)
    require('leap').add_default_mappings()
  end,
}
