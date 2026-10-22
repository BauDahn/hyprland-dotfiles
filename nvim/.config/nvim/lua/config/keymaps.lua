local map = vim.keymap.set

-- Leader: espacio
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Básicos
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Quitar resaltado" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Guardar" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Cerrar ventana" })

-- Moverse entre splits con Ctrl+hjkl
map("n", "<C-h>", "<C-w>h", { desc = "Ventana izquierda" })
map("n", "<C-j>", "<C-w>j", { desc = "Ventana abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Ventana arriba" })
map("n", "<C-l>", "<C-w>l", { desc = "Ventana derecha" })

-- Redimensionar splits
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Más alto" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Más bajo" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Más angosto" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Más ancho" })

-- Centrar al saltar páginas y búsquedas
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Buffer anterior" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Buffer siguiente" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Cerrar buffer" })

-- Mover bloques seleccionados
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover abajo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover arriba" })

-- Indentar sin perder la selección
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Pegar sin reemplazar el registro
map("x", "<leader>p", '"_dP', { desc = "Pegar sin copiar" })

-- Diagnósticos
map("n", "<leader>xd", vim.diagnostic.open_float, { desc = "Diagnóstico" })
