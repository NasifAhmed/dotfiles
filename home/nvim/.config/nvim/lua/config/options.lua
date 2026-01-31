-- ==========================================================================
-- ==========================================================================

-- 1. INDENTATION (4 Spaces)
vim.opt.tabstop = 4       -- Width of tab character
vim.opt.shiftwidth = 4    -- Width of auto-indent
vim.opt.expandtab = true  -- Use spaces instead of tabs
vim.opt.softtabstop = 4   -- Backspace deletes 4 spaces at once
vim.opt.autoindent = true -- Inherit indentation

-- 2. WRAPPING & WIDTH
vim.opt.formatoptions:append("tc")
vim.opt.wrap = true        -- Enable wrapping
vim.opt.linebreak = true   -- Wrap nicely at words
vim.opt.textwidth = 80     -- Hard wrap limit
vim.opt.colorcolumn = "80" -- Visual guide line

-- 3. VISUALS
vim.opt.cursorline = true   -- Highlight current line
vim.opt.cursorcolumn = true -- Highlight current column
vim.opt.list = true         -- Show invisible chars
vim.opt.listchars = { space = '·', tab = '» ', trail = '·', nbsp = '␣' }

-- 4. AUTO-INDENT ON SAVE (Native Engine)
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local view = vim.fn.winsaveview() -- Save cursor position
        vim.cmd('normal! gg=G')           -- Indent whole file
        vim.fn.winrestview(view)          -- Restore cursor position
    end,
})

-- 5. PRESENTATION MODE TOGGLE
-- Maps <Space> + z to toggle everything (including top tabs)
vim.keymap.set("n", "<leader>z", function()
    -- Use 'vim.o' instead of 'vim.opt:get()' to avoid the LSP error
    if vim.o.showtabline == 0 then
        -- [ EXIT PRESENTATION MODE ]
        vim.opt.laststatus = 3     -- Restore Global Status bar
        vim.opt.showtabline = 2    -- Restore Top Tabs
        vim.opt.showmode = true    -- Show "-- INSERT --"
        vim.opt.number = true      -- Show line numbers
        vim.opt.signcolumn = "yes" -- Restore git signs
        print("Presentation Mode: OFF")
    else
        -- [ ENTER PRESENTATION MODE ]
        vim.opt.laststatus = 0    -- Hide Status bar
        vim.opt.showtabline = 0   -- Hide Top Tabs
        vim.opt.showmode = false  -- Hide mode text
        vim.opt.number = false    -- Hide line numbers
        vim.opt.signcolumn = "no" -- Hide git signs
        print("Presentation Mode: ON")
    end
end, { desc = "Toggle Presentation Mode" })
