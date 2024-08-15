return {
    "TabbyML/vim-tabby",
    event = "BufEnter",
    init = function() vim.g.tabby_keybinding_accept = '<C-]>' end
}
