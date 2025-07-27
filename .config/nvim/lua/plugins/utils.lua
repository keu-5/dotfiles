return {
    -- ステータスライン
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        config = function()
            require("lualine").setup({
                options = {
                    icons_enabled = true,
                    theme = "catppuccin",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = {
                        statusline = {},
                        winbar = {},
                    },
                    ignore_focus = {},
                    always_divide_middle = true,
                    globalstatus = true,
                    refresh = {
                        statusline = 1000,
                        tabline = 1000,
                        winbar = 1000,
                    }
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = {
                        {
                            "filename",
                            file_status = true,
                            newfile_status = false,
                            path = 1, -- 相対パスを表示
                        }
                    },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" }
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {}
                },
                tabline = {},
                winbar = {},
                inactive_winbar = {},
                extensions = { "nvim-tree", "lazy" }
            })
        end,
    },

    -- Git統合
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("gitsigns").setup({
                signs = {
                    add          = { text = "│" },
                    change       = { text = "│" },
                    delete       = { text = "_" },
                    topdelete    = { text = "‾" },
                    changedelete = { text = "~" },
                    untracked    = { text = "┆" },
                },
                signcolumn = true,
                numhl = false,
                linehl = false,
                word_diff = false,
                watch_gitdir = {
                    follow_files = true
                },
                attach_to_untracked = true,
                current_line_blame = false,
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = "eol",
                    delay = 1000,
                    ignore_whitespace = false,
                },
                current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
                sign_priority = 6,
                update_debounce = 100,
                status_formatter = nil,
                max_file_length = 40000,
                preview_config = {
                    border = "single",
                    style = "minimal",
                    relative = "cursor",
                    row = 0,
                    col = 1
                },
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map("n", "]c", function()
                        if vim.wo.diff then return "]c" end
                        vim.schedule(function() gs.next_hunk() end)
                        return "<Ignore>"
                    end, { expr = true, desc = "次の変更箇所" })

                    map("n", "[c", function()
                        if vim.wo.diff then return "[c" end
                        vim.schedule(function() gs.prev_hunk() end)
                        return "<Ignore>"
                    end, { expr = true, desc = "前の変更箇所" })

                    -- Actions
                    map("n", "<leader>hs", gs.stage_hunk, { desc = "Hunkをステージ" })
                    map("n", "<leader>hr", gs.reset_hunk, { desc = "Hunkをリセット" })
                    map("v", "<leader>hs", function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end,
                        { desc = "選択範囲をステージ" })
                    map("v", "<leader>hr", function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end,
                        { desc = "選択範囲をリセット" })
                    map("n", "<leader>hS", gs.stage_buffer, { desc = "バッファをステージ" })
                    map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "ステージを取り消し" })
                    map("n", "<leader>hR", gs.reset_buffer, { desc = "バッファをリセット" })
                    map("n", "<leader>hp", gs.preview_hunk, { desc = "Hunkをプレビュー" })
                    map("n", "<leader>hb", function() gs.blame_line { full = true } end, { desc = "行のBlame" })
                    map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Blameの切り替え" })
                    map("n", "<leader>hd", gs.diffthis, { desc = "Diff表示" })
                    map("n", "<leader>hD", function() gs.diffthis("~") end, { desc = "Diff表示（HEAD）" })
                    map("n", "<leader>td", gs.toggle_deleted, { desc = "削除行の表示切り替え" })

                    -- Text object
                    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Hunkを選択" })
                end
            })
        end,
    },

    -- コメントアウト
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        config = function()
            -- enable comment
            require("Comment").setup({
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
            })
        end,
    },

    -- 自動ペア
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,
                ts_config = {
                    lua = { "string", "source" },
                    javascript = { "string", "template_string" },
                    java = false,
                },
                disable_filetype = { "TelescopePrompt", "spectre_panel" },
                fast_wrap = {
                    map = "<M-e>",
                    chars = { "{", "[", "(", '"', "'" },
                    pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
                    offset = 0,
                    end_key = "$",
                    keys = "qwertyuiopzxcvbnmasdfghjkl",
                    check_comma = true,
                    highlight = "PmenuSel",
                    highlight_grey = "LineNr",
                },
            })

            -- cmpとの統合
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            local cmp = require("cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },

    -- インデントガイド
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("ibl").setup({
                indent = {
                    char = "│",
                    tab_char = "│",
                },
                scope = { enabled = false },
                exclude = {
                    filetypes = {
                        "help",
                        "alpha",
                        "dashboard",
                        "neo-tree",
                        "Trouble",
                        "lazy",
                        "mason",
                        "notify",
                        "toggleterm",
                        "lazyterm",
                    },
                },
            })
        end,
    },

    -- バッファライン
    {
        "akinsho/bufferline.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        version = "*",
        event = "VeryLazy",
        keys = {
            -- 従来のキーマッピング
            { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "バッファをピン留め" },
            { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "ピン留めしていないバッファを閉じる" },
            { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "他のバッファを閉じる" },
            { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "右のバッファを閉じる" },
            { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "左のバッファを閉じる" },
            { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "前のバッファ" },
            { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "次のバッファ" },
            { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "前のバッファ" },
            { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "次のバッファ" },
        },
        config = function()
            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    separator_style = "slant",
                    always_show_bufferline = false,
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    color_icons = true,
                    diagnostics = "nvim_lsp",
                    diagnostics_update_in_insert = false,
                    offsets = {
                        {
                            filetype = "NvimTree",
                            text = "File Explorer",
                            text_align = "left",
                            separator = true,
                        },
                    },
                },
            })
        end,
    },

    -- コマンド表示等
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            -- add any options here
        },
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        }
    },
}
