local opt = vim.opt

-- Interfaz
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.scrolloff = 8
opt.wrap = false
opt.showmode = false -- lo muestra lualine
opt.confirm = true -- pregunta en vez de fallar al cerrar con cambios
opt.splitright = true
opt.splitbelow = true
opt.fillchars = { eob = " " }

-- Edición
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- usa el portapapeles del sistema (wl-clipboard en Wayland)
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.undofile = true

-- Rendimiento y respuesta
opt.updatetime = 250
opt.timeoutlen = 300
