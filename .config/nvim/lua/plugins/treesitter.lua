return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
        require("nvim-treesitter.configs").setup({
            -- パーサーを自動インストール
            ensure_installed = {
                "lua", "vim", "vimdoc", "query",
                "javascript", "typescript", "tsx",
                "html", "css", "json", "yaml",
                "python", "rust", "go", "c", "cpp",
                "bash", "markdown", "markdown_inline",
            },

            -- 自動インストールを有効化
            auto_install = true,

            -- シンタックスハイライト
            highlight = {
                enable = true,
                -- 大きなファイルでは無効化
                disable = function(lang, buf)
                    local max_filesize = 100 * 1024 -- 100 KB
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end
                end,
                additional_vim_regex_highlighting = false,
            },

            -- インデント
            indent = {
                enable = true,
                disable = { "python" }, -- Pythonではネイティブインデントを使用
            },

            -- 増分選択
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },

            -- テキストオブジェクト
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        -- 関数
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        -- クラス
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                        -- 条件文
                        ["ai"] = "@conditional.outer",
                        ["ii"] = "@conditional.inner",
                        -- ループ
                        ["al"] = "@loop.outer",
                        ["il"] = "@loop.inner",
                        -- パラメータ
                        ["ap"] = "@parameter.outer",
                        ["ip"] = "@parameter.inner",
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]f"] = "@function.outer",
                        ["]c"] = "@class.outer",
                    },
                    goto_next_end = {
                        ["]F"] = "@function.outer",
                        ["]C"] = "@class.outer",
                    },
                    goto_previous_start = {
                        ["[f"] = "@function.outer",
                        ["[c"] = "@class.outer",
                    },
                    goto_previous_end = {
                        ["[F"] = "@function.outer",
                        ["[C"] = "@class.outer",
                    },
                },
            },
        })
    end,
}
