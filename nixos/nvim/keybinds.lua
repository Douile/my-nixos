-- Switch tab keybinds
vim.keymap.set('n', '<C-j>', '<cmd>tabprevious<cr>')
vim.keymap.set('n', '<C-k>', '<cmd>tabnext<cr>')

-- Disable macros
vim.keymap.set('n', '<q>', '<nop>')

-- Clear search
vim.keymap.set('n', '<F3>', '<cmd>set hlsearch!<cr>')
