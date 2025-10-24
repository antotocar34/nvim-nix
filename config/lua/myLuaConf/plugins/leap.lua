return {
  "leap.nvim",
  for_cat = 'general.extra',
  event = "DeferredUIEnter",
  after = function(_)
    require('leap').add_default_mappings()
  end,
}
