return {
  "comment.nvim",
  for_cat = 'general.extra',
  event = "DeferredUIEnter",
  after = function(_)
    require('Comment').setup()
  end,
}
