-- Relative line numbers
vim.opt.nu = true
--vim.opt.relativenumber = true

-- 4 space indent
vim.opt.tabstop = 4  
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = false

-- Enable cursorline and cusromcolumn
vim.opt.cursorline = true
vim.opt.cursorcolumn = true

-- Increamental search but doesn't stay highlighted
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

-- Stop scrolling to the bottom. Always keep 8 line padding.
vim.opt.scrolloff = 8

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

vim.opt.colorcolumn = "80"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true


-- Set colorscheme from default ones
vim.cmd.colorscheme('habamax')
