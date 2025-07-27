return {
    -- ファイルエクスプローラー
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = "nvim-tree/nvim-web-devicons",
        cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus" },
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "ファイルツリー切り替え" },
            {
                "<leader>p",
                function()
                    local function show_file_modal()
                        local cwd = vim.fn.getcwd()
                        local files = vim.fn.globpath(cwd, "*", 0, 1)
                        local dirs = {}
                        local regular_files = {}

                        -- ディレクトリとファイルを分類
                        for _, file in ipairs(files) do
                            local filename = vim.fn.fnamemodify(file, ":t")
                            -- 隠しファイルをスキップ（.で始まるもの）しない
                            if vim.fn.isdirectory(file) == 1 then
                                table.insert(dirs, { name = filename, path = file, type = "dir" })
                            else
                                table.insert(regular_files, { name = filename, path = file, type = "file" })
                            end
                        end

                        -- ソート
                        table.sort(dirs, function(a, b) return a.name < b.name end)
                        table.sort(regular_files, function(a, b) return a.name < b.name end)

                        -- 結合
                        local all_items = {}
                        for _, dir in ipairs(dirs) do
                            table.insert(all_items, dir)
                        end
                        for _, file in ipairs(regular_files) do
                            table.insert(all_items, file)
                        end

                        -- モーダルウィンドウの作成
                        local width = 70
                        local height = math.min(#all_items + 12, 25)
                        local row = math.floor((vim.o.lines - height) / 2)
                        local col = math.floor((vim.o.columns - width) / 2)

                        local buf = vim.api.nvim_create_buf(false, true)
                        local content = {
                            "📂 File Explorer - " .. vim.fn.fnamemodify(cwd, ":t"),
                            "📍 " .. cwd,
                            ""
                        }

                        for i, item in ipairs(all_items) do
                            local icon = item.type == "dir" and "📁" or "📄"
                            local line = string.format("%2d. %s %s", i, icon, item.name)
                            table.insert(content, line)
                        end

                        table.insert(content, "")
                        table.insert(content, "キー操作:")
                        table.insert(content, "  数字/Enter: ファイル/ディレクトリを開く")
                        table.insert(content, "  A: ディレクトリを作成")
                        table.insert(content, "  a: ファイルを作成")
                        table.insert(content, "  d: ファイル/ディレクトリを削除")
                        table.insert(content, "  r: リネーム")
                        table.insert(content, "  t: ツリー表示切り替え")
                        table.insert(content, "  ..: 親ディレクトリへ")
                        table.insert(content, "  q/Esc: 閉じる")

                        vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

                        local win = vim.api.nvim_open_win(buf, true, {
                            relative = "editor",
                            width = width,
                            height = height,
                            row = row,
                            col = col,
                            style = "minimal",
                            border = "rounded",
                            title = " File Explorer ",
                            title_pos = "center"
                        })

                        -- バッファオプション
                        vim.bo[buf].modifiable = false
                        vim.bo[buf].readonly = true
                        vim.bo[buf].filetype = "file-modal"

                        -- ハイライト設定
                        vim.api.nvim_set_hl(0, "FileModalTitle", { fg = "#89b4fa", bold = true })
                        vim.api.nvim_set_hl(0, "FileModalPath", { fg = "#94e2d5", italic = true })
                        vim.api.nvim_set_hl(0, "FileModalDir", { fg = "#f9e2af", bold = true })
                        vim.api.nvim_set_hl(0, "FileModalFile", { fg = "#cdd6f4" })

                        -- ハイライト適用
                        vim.api.nvim_buf_add_highlight(buf, -1, "FileModalTitle", 0, 0, -1)
                        vim.api.nvim_buf_add_highlight(buf, -1, "FileModalPath", 1, 0, -1)

                        local function close_modal()
                            if vim.api.nvim_win_is_valid(win) then
                                vim.api.nvim_win_close(win, true)
                            end
                        end

                        local function refresh_modal()
                            close_modal()
                            vim.defer_fn(function()
                                show_file_modal()
                            end, 50)
                        end

                        local function open_item(index)
                            if all_items[index] then
                                local item = all_items[index]
                                close_modal()

                                if item.type == "dir" then
                                    vim.cmd("cd " .. vim.fn.fnameescape(item.path))
                                    -- ディレクトリの場合は再度モーダルを開く
                                    vim.defer_fn(function()
                                        show_file_modal()
                                    end, 50)
                                else
                                    vim.cmd("edit " .. vim.fn.fnameescape(item.path))
                                end
                            end
                        end

                        local function create_directory()
                            close_modal()
                            vim.ui.input({ prompt = "ディレクトリ名: " }, function(input)
                                if input and input ~= "" then
                                    local dir_path = vim.fn.expand(cwd .. "/" .. input)
                                    vim.fn.mkdir(dir_path, "p")
                                    vim.notify("ディレクトリを作成しました: " .. input, vim.log.levels.INFO)
                                    refresh_modal()
                                else
                                    refresh_modal()
                                end
                            end)
                        end

                        local function create_file()
                            close_modal()
                            vim.ui.input({ prompt = "ファイル名: " }, function(input)
                                if input and input ~= "" then
                                    local file_path = vim.fn.expand(cwd .. "/" .. input)
                                    -- ディレクトリが存在しない場合は作成
                                    local dir = vim.fn.fnamemodify(file_path, ":h")
                                    vim.fn.mkdir(dir, "p")
                                    -- 空のファイルを作成
                                    vim.fn.writefile({}, file_path)
                                    vim.notify("ファイルを作成しました: " .. input, vim.log.levels.INFO)
                                    -- ファイルを開く
                                    vim.cmd("edit " .. vim.fn.fnameescape(file_path))
                                else
                                    refresh_modal()
                                end
                            end)
                        end

                        local function delete_item()
                            local line_num = vim.api.nvim_win_get_cursor(win)[1]
                            local item_index = line_num - 3 -- ヘッダー分を除く

                            if item_index > 0 and item_index <= #all_items then
                                local item = all_items[item_index]
                                close_modal()

                                local confirm_msg = string.format("本当に '%s' を削除しますか？ (y/N): ", item.name)
                                vim.ui.input({ prompt = confirm_msg }, function(input)
                                    if input and (input:lower() == "y" or input:lower() == "yes") then
                                        if item.type == "dir" then
                                            -- ディレクトリの削除（中身があっても削除）
                                            vim.fn.delete(item.path, "rf")
                                        else
                                            -- ファイルの削除
                                            vim.fn.delete(item.path)
                                        end
                                        vim.notify("削除しました: " .. item.name, vim.log.levels.INFO)
                                    end
                                    refresh_modal()
                                end)
                            end
                        end

                        local function rename_item()
                            local line_num = vim.api.nvim_win_get_cursor(win)[1]
                            local item_index = line_num - 3 -- ヘッダー分を除く

                            if item_index > 0 and item_index <= #all_items then
                                local item = all_items[item_index]
                                close_modal()

                                vim.ui.input({
                                    prompt = "新しい名前: ",
                                    default = item.name
                                }, function(input)
                                    if input and input ~= "" and input ~= item.name then
                                        local new_path = vim.fn.expand(cwd .. "/" .. input)
                                        local success = vim.loop.fs_rename(item.path, new_path)
                                        if success then
                                            vim.notify("リネームしました: " .. item.name .. " → " .. input, vim.log.levels.INFO)
                                        else
                                            vim.notify("リネームに失敗しました", vim.log.levels.ERROR)
                                        end
                                    end
                                    refresh_modal()
                                end)
                            end
                        end

                        -- 数字キーでファイル/ディレクトリを開く
                        for i = 1, math.min(#all_items, 9) do
                            vim.keymap.set("n", tostring(i), function()
                                open_item(i)
                            end, { buffer = buf, nowait = true })
                        end

                        -- その他のキーマッピング
                        vim.keymap.set("n", "<CR>", function()
                            local line_num = vim.api.nvim_win_get_cursor(win)[1]
                            local item_index = line_num - 3 -- ヘッダー分を除く
                            if item_index > 0 and item_index <= #all_items then
                                open_item(item_index)
                            end
                        end, { buffer = buf, nowait = true })

                        -- ファイル操作
                        vim.keymap.set("n", "A", create_directory, { buffer = buf, nowait = true })
                        vim.keymap.set("n", "a", create_file, { buffer = buf, nowait = true })
                        vim.keymap.set("n", "d", delete_item, { buffer = buf, nowait = true })
                        vim.keymap.set("n", "r", rename_item, { buffer = buf, nowait = true })

                        -- ナビゲーション
                        vim.keymap.set("n", "q", close_modal, { buffer = buf, nowait = true })
                        vim.keymap.set("n", "<Esc>", close_modal, { buffer = buf, nowait = true })

                        vim.keymap.set("n", "t", function()
                            close_modal()
                            vim.cmd("NvimTreeToggle")
                        end, { buffer = buf, nowait = true })

                        vim.keymap.set("n", "..", function()
                            close_modal()
                            vim.cmd("cd ..")
                            vim.defer_fn(function()
                                show_file_modal()
                            end, 50)
                        end, { buffer = buf, nowait = true })

                        -- カーソル移動
                        vim.keymap.set("n", "j", function()
                            local current_line = vim.api.nvim_win_get_cursor(win)[1]
                            local max_line = #content
                            if current_line < max_line then
                                vim.api.nvim_win_set_cursor(win, { current_line + 1, 0 })
                            end
                        end, { buffer = buf, nowait = true })

                        vim.keymap.set("n", "k", function()
                            local current_line = vim.api.nvim_win_get_cursor(win)[1]
                            if current_line > 1 then
                                vim.api.nvim_win_set_cursor(win, { current_line - 1, 0 })
                            end
                        end, { buffer = buf, nowait = true })

                        -- 初期カーソル位置を最初のファイル/ディレクトリに設定
                        if #all_items > 0 then
                            vim.api.nvim_win_set_cursor(win, { 4, 0 }) -- 最初のアイテム
                        end

                        -- ウィンドウが閉じられた時の処理
                        vim.api.nvim_create_autocmd("WinClosed", {
                            pattern = tostring(win),
                            callback = function()
                                if vim.api.nvim_buf_is_valid(buf) then
                                    vim.api.nvim_buf_delete(buf, { force = true })
                                end
                            end,
                            once = true
                        })
                    end

                    show_file_modal()
                end,
                desc = "ファイルエクスプローラー（モーダル）"
            },
        },
        config = function()
            -- netrwを無効化
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            require("nvim-tree").setup({
                sort_by = "case_sensitive",
                view = {
                    width = 30,
                    preserve_window_proportions = true,
                },
                renderer = {
                    group_empty = true,
                    icons = {
                        glyphs = {
                            default = "",
                            symlink = "",
                            folder = {
                                arrow_closed = "",
                                arrow_open = "",
                                default = "",
                                open = "",
                                empty = "",
                                empty_open = "",
                                symlink = "",
                                symlink_open = "",
                            },
                            git = {
                                unstaged = "✗",
                                staged = "✓",
                                unmerged = "",
                                renamed = "➜",
                                untracked = "★",
                                deleted = "",
                                ignored = "◌",
                            },
                        },
                    },
                },
                filters = {
                    dotfiles = false,
                },
                git = {
                    enable = true,
                    ignore = false,
                    timeout = 500,
                },
                actions = {
                    open_file = {
                        quit_on_open = false,
                        resize_window = true,
                    },
                },
                update_focused_file = {
                    enable = true,
                    update_cwd = true,
                    ignore_list = {},
                },
            })
        end,
    },

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
}
