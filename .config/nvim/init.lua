-- =============================================
-- Neovim 基本設定
-- =============================================

-- vscodeではリーダーキーを設定しない
if vim.g.vscode then
    vim.g.mapleader = "<nop>"

    vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
    vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })
else
    vim.g.mapleader = " "
end

-- リーダーキーの設定（lazy.nvimより先に設定する必要がある）
vim.g.maplocalleader = "\\"

-- 基本設定
local opt = vim.opt

-- 表示設定
opt.number = true         -- 行番号表示
opt.relativenumber = true -- 相対行番号
opt.signcolumn = "yes"    -- サインカラムを常に表示
opt.wrap = false          -- 行の折り返しを無効
opt.scrolloff = 8         -- スクロール時の余白
opt.sidescrolloff = 8     -- 横スクロール時の余白
opt.cursorline = true     -- カーソル行をハイライト

-- インデント設定
opt.tabstop = 4        -- タブの幅
opt.shiftwidth = 4     -- インデントの幅
opt.expandtab = true   -- タブをスペースに変換
opt.autoindent = true  -- 自動インデント
opt.smartindent = true -- スマートインデント

-- 検索設定
opt.ignorecase = true -- 大文字小文字を無視
opt.smartcase = true  -- 大文字が含まれる場合は大文字小文字を区別
opt.hlsearch = true   -- 検索結果をハイライト
opt.incsearch = true  -- インクリメンタル検索

-- ファイル設定
opt.backup = false      -- バックアップファイルを作成しない
opt.writebackup = false -- 書き込み時のバックアップを無効
opt.swapfile = false    -- スワップファイルを作成しない
opt.undofile = true     -- アンドゥファイルを有効
opt.updatetime = 50     -- 更新間隔を短縮

-- その他
opt.guifont = "Hack Nerd Font Mono" -- フォント設定
opt.termguicolors = true            -- True colorを有効
opt.mouse = "a"                     -- マウスサポートを有効
opt.clipboard = "unnamedplus"       -- システムクリップボードを使用
opt.splitbelow = true               -- 新しいウィンドウを下に分割
opt.splitright = true               -- 新しいウィンドウを右に分割

-- =============================================
-- lazy.nvim のブートストラップ
-- =============================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    print("Installing lazy.nvim...")
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "--branch=stable", lazyrepo, lazypath
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
    print("lazy.nvim installed successfully!")
end
vim.opt.rtp:prepend(lazypath)

-- =============================================
-- プラグインの読み込み
-- =============================================

require("lazy").setup({
    spec = {
        { import = "plugins" }, -- pluginsディレクトリからインポート
    },
}, require("config.lazy"))

-- =============================================
-- 基本キーマップ
-- =============================================

local keymap = vim.keymap.set

-- 一般的なキーマップ
keymap("n", "sh", "<C-w>h", { desc = "左のウィンドウに移動" })
keymap("n", "sj", "<C-w>j", { desc = "下のウィンドウに移動" })
keymap("n", "sk", "<C-w>k", { desc = "上のウィンドウに移動" })
keymap("n", "sl", "<C-w>l", { desc = "右のウィンドウに移動" })

-- 検索結果のハイライトを消去
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "検索ハイライトを消去" })

-- より良いインデント（ビジュアルモードで選択を維持）
keymap("v", "<", "<gv", { desc = "インデントを左に" })
keymap("v", ">", ">gv", { desc = "インデントを右に" })

-- 行の移動
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "選択した行を下に移動" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "選択した行を上に移動" })

-- 中央に保持しながらのページ移動
keymap("n", "<C-d>", "<C-d>zz", { desc = "半ページ下に移動して中央に" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "半ページ上に移動して中央に" })

-- normalモードに戻る
keymap("i", "jj", "<Esc>", { desc = "jjでnormalモードに戻る" })

-- =============================================
-- 自動コマンド
-- =============================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ハイライトグループ
local highlight_group = augroup("YankHighlight", {})
autocmd("TextYankPost", {
    group = highlight_group,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 40,
        })
    end,
})

-- ファイルタイプ別の設定
local filetype_group = augroup("FileTypeSettings", {})
autocmd("FileType", {
    group = filetype_group,
    pattern = { "lua", "javascript", "typescript", "json", "html", "css" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})
