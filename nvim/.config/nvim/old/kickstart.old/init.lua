--[[
================================================================================

--       ████     ██ ████████   ███████   ██      ██ ██ ████     ████
--      ░██░██   ░██░██░░░░░   ██░░░░░██ ░██     ░██░██░██░██   ██░██
--      ░██░░██  ░██░██       ██     ░░██░██     ░██░██░██░░██ ██ ░██
--      ░██ ░░██ ░██░███████ ░██      ░██░░██    ██ ░██░██ ░░███  ░██
--      ░██  ░░██░██░██░░░░  ░██      ░██ ░░██  ██  ░██░██  ░░█   ░██
--      ░██   ░░████░██      ░░██     ██   ░░████   ░██░██   ░    ░██
--      ░██    ░░███░████████ ░░███████     ░░██    ░██░██        ░██
--      ░░      ░░░ ░░░░░░░░   ░░░░░░░       ░░     ░░ ░░         ░░ 

================================================================================

This is my final neovim setup. Goal is to create a personalized minimal neovim 
setup as I keep getting used to neovim as my main editor.

This mainly started from the Primeagen's video titled "0 to LSP". But found that
all very over-whelming. Still I followed along and got to pretty decent setup.
But didn't understand half of what I did or what to do if something breaks. So 
deleted everything and started from sratch again.
Then took some stuff from the mentioned video and other kickstart.nvim project 
and from random youtube videos/forum posts/articles.
Will keep adding stuff.

- Ahmed , February 2023

--]]

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--  NOTE: Must happen before plugins are required (otherwise wrong leader will 
--  be used)
-------------------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--
--   Various tweaks
--
--
-------------------------------------------------------------------------------

-- Relative line numbers
vim.opt.number = true
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

-- Decrease update tfme
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

vim.opt.colorcolumn = "80"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Make the system clipboard the default copy/cut register
vim.opt.clipboard = "unnamedplus"


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--
--   lazy.nvim setup
--
--
-------------------------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-------------------------------------------------------------------------------
--
--
--   Plugins install
--
--
-------------------------------------------------------------------------------

require('lazy').setup({

    -- telescope (its a fuzzy search for file/word/symbol search)
    { 'nvim-telescope/telescope.nvim', version = '*', 
        dependencies = { 'nvim-lua/plenary.nvim' } },

    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
            return vim.fn.executable 'make' == 1
        end,
    },

    -- Treesitter setup
    -- Highlight, edit, and navigate code
    { 
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        config = function()
            pcall(require('nvim-treesitter.install').update { with_sync = true })
        end,
    },

    {
        "folke/which-key.nvim",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require("which-key").setup({
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            })
        end,
    },

    { -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        opts = {
            char = '┊',
            show_trailing_blankline_indent = false,
        },
    },

    -- Detect tabstop and shiftwidth automatically
    { 'tpope/vim-sleuth' },

    { -- Theme inspired by Atom
        'navarasu/onedark.nvim',
        priority = 1000,
        config = function()
            vim.cmd.colorscheme 'onedark'
        end,
    },

    { -- Set lualine as statusline
        'nvim-lualine/lualine.nvim',
        -- See `:help lualine.txt`
        opts = {
            options = {
                theme = 'onedark',
                component_separators = '|',
                section_separators = '',
            },
        },
    },

    { 'norcalli/nvim-colorizer.lua' },

    { 'vimpostor/vim-lumen' },

    { "catppuccin/nvim", name = "catppuccin" },

    { 'Mofiqul/dracula.nvim' },
    
    { 'EdenEast/nightfox.nvim' },
     
    { 'ishan9299/nvim-solarized-lua' },

    { 'ms-jpq/coq_nvim' },


})

-------------------------------------------------------------------------------
--
--
--   Plugins setup
--
--
-------------------------------------------------------------------------------

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
    },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')


-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 
        'typescript', 'help', 'vim' },
    highlight = { enable = true },
    indent = { enable = true, disable = { 'python' } },
}

require('onedark').setup {
    style = 'warmer'
}
require('onedark').load()

require'colorizer'.setup()


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--
--   Keybindings
--
--
-------------------------------------------------------------------------------


-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, 
    { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, 
    { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, 
    -- layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(
        require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
        })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, 
    { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, 
    { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, 
    { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, 
    { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, 
    { desc = '[S]earch [D]iagnostics' })


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--
--   Netrew setup
--
--
-------------------------------------------------------------------------------

-- netrw configs
---- Open file under cursor same window down
--nnoremap <leader>oj :wincmd f<CR>
--map <leader>oj :wincmd f<CR>
--
---- Open file under cursor same window left
--nnoremap <leader>ol :vertical wincmd f<CR>
--map <leader>ol :vertical wincmd f<CR>
--
---- Open file under cursor new window
--nnoremap <leader>o<leader> :wincmd gf<CR>
--map <leader>o<leader> :wincmd gf<CR>
--
---- File Manager
---- https://superuser.com/questions/31677/how-do-i-open-the-directory-of-the-current-open-file
--map <leader>.j :Sex<CR>
--map <leader>.h :Vex<CR>
--map <leader>f. :30vs .<CR>
--
