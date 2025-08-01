return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        lazy = false,
        config = function()
            require("neo-tree").setup({
                close_if_last_window = false,
                popup_border_style = "rounded",
                enable_git_status = true,
                enable_diagnostics = true,
                open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
                open_files_using_relative_paths = false,
                sort_case_insensitive = false,
                sort_function = nil,
                default_component_configs = {
                    container = {
                        enable_character_fade = true,
                    },
                    indent = {
                        indent_size = 2,
                        padding = 1,
                        with_markers = true,
                        indent_marker = "│",
                        last_indent_marker = "└",
                        highlight = "NeoTreeIndentMarker",
                        with_expanders = nil,
                        expander_collapsed = "",
                        expander_expanded = "",
                        expander_highlight = "NeoTreeExpander",
                    },
                    icon = {
                        folder_closed = "󰉋",
                        folder_open = "󰝰",
                        folder_empty = "󰜌",
                        folder_empty_open = "󰜌",
                        -- Simplified and reliable provider
                        provider = function(icon, node, state)
                            if node.type == "file" or node.type == "terminal" then
                                local success, web_devicons = pcall(require, "nvim-web-devicons")
                                if success then
                                    local name = node.type == "terminal" and "terminal" or node.name
                                    local devicon, hl = web_devicons.get_icon(name)
                                    if devicon then
                                        icon.text = devicon
                                        icon.highlight = hl or icon.highlight
                                    end
                                end
                            end
                        end,
                        default = "",
                        highlight = "NeoTreeFileIcon",
                    },
                    modified = {
                        symbol = "[+]",
                        highlight = "NeoTreeModified",
                    },
                    name = {
                        trailing_slash = false,
                        use_git_status_colors = true,
                        highlight = "NeoTreeFileName",
                    },
                    git_status = {
                        symbols = {
                            added = "",    -- or "✚"
                            modified = "", -- or ""
                            deleted = "✖",
                            renamed = "󰁕",
                            untracked = "",
                            ignored = "",
                            unstaged = "󰄱",
                            staged = "",
                            conflict = "",
                        },
                    },
                    file_size = {
                        enabled = true,
                        width = 12,
                        required_width = 64,
                    },
                    type = {
                        enabled = true,
                        width = 10,
                        required_width = 122,
                    },
                    last_modified = {
                        enabled = true,
                        width = 20,
                        required_width = 88,
                    },
                    created = {
                        enabled = true,
                        width = 20,
                        required_width = 110,
                    },
                    symlink_target = {
                        enabled = false,
                    },
                },
                commands = {},
                window = {
                    position = "float",
                    width = 50,
                    height = 25,
                    popup = {
                        position = { col = "50%", row = "50%" },
                        size = {
                            width = "50%",
                            height = "60%",
                        },
                        border = {
                            style = "rounded",
                            highlight = "FloatBorder",
                            text = {
                                top = " Neo-tree ",
                                top_align = "center",
                            },
                        },
                    },
                    mapping_options = {
                        noremap = true,
                        nowait = true,
                    },
                    mappings = {
                        ["<space>"] = {
                            "toggle_node",
                            nowait = false,
                        },
                        ["<2-LeftMouse>"] = "open",
                        ["<cr>"] = "open",
                        ["<esc>"] = "cancel",
                        ["P"] = {
                            "toggle_preview",
                            config = {
                                use_float = true,
                                use_snacks_image = true,
                                use_image_nvim = true,
                            },
                        },
                        ["l"] = "focus_preview",
                        ["S"] = "open_split",
                        ["s"] = "open_vsplit",
                        -- ["S"] = "split_with_window_picker",
                        -- ["s"] = "vsplit_with_window_picker",
                        ["t"] = "open_tabnew",
                        -- ["<cr>"] = "open_drop",
                        -- ["t"] = "open_tab_drop",
                        ["w"] = "open_with_window_picker",
                        --["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
                        ["C"] = "close_node",
                        -- ['C'] = 'close_all_subnodes',
                        ["z"] = "close_all_nodes",
                        --["Z"] = "expand_all_nodes",
                        --["Z"] = "expand_all_subnodes",
                        ["a"] = {
                            "add",
                            config = {
                                show_path = "none", -- "none", "relative", "absolute"
                            },
                        },
                        ["A"] = "add_directory",
                        ["d"] = "delete",
                        ["r"] = "rename",
                        ["b"] = "rename_basename",
                        ["y"] = "copy_to_clipboard",
                        ["x"] = "cut_to_clipboard",
                        ["p"] = "paste_from_clipboard",
                        ["c"] = "copy",
                        ["m"] = "move",
                        ["q"] = "close_window",
                        ["R"] = "refresh",
                        ["?"] = "show_help",
                        ["<"] = "prev_source",
                        [">"] = "next_source",
                        ["i"] = "show_file_details",
                    },
                },
                nesting_rules = {},
                filesystem = {
                    filtered_items = {
                        visible = false,
                        hide_dotfiles = true,
                        hide_gitignored = true,
                        hide_hidden = true,
                        hide_by_name = {
                            --"node_modules"
                        },
                        hide_by_pattern = {
                            --"*.meta",
                            --"*/src/*/tsconfig.json",
                        },
                        always_show = {
                            --".gitignored",
                        },
                        always_show_by_pattern = {
                            --".env*",
                        },
                        never_show = {
                            --".DS_Store",
                            --"thumbs.db"
                        },
                        never_show_by_pattern = {
                            --".null-ls_*",
                        },
                    },
                    follow_current_file = {
                        enabled = false,
                        leave_dirs_open = false,
                    },
                    group_empty_dirs = false,
                    hijack_netrw_behavior = "open_default",

                    use_libuv_file_watcher = false,
                    window = {
                        mappings = {
                            ["<bs>"] = "navigate_up",
                            ["."] = "set_root",
                            ["H"] = "toggle_hidden",
                            ["/"] = "fuzzy_finder",
                            ["D"] = "fuzzy_finder_directory",
                            ["#"] = "fuzzy_sorter",
                            -- ["D"] = "fuzzy_sorter_directory",
                            ["f"] = "filter_on_submit",
                            ["<c-x>"] = "clear_filter",
                            ["[g"] = "prev_git_modified",
                            ["]g"] = "next_git_modified",
                            ["o"] = {
                                "show_help",
                                nowait = false,
                                config = { title = "Order by", prefix_key = "o" },
                            },
                            ["oc"] = { "order_by_created", nowait = false },
                            ["od"] = { "order_by_diagnostics", nowait = false },
                            ["og"] = { "order_by_git_status", nowait = false },
                            ["om"] = { "order_by_modified", nowait = false },
                            ["on"] = { "order_by_name", nowait = false },
                            ["os"] = { "order_by_size", nowait = false },
                            ["ot"] = { "order_by_type", nowait = false },
                        },
                        fuzzy_finder_mappings = {
                            ["<down>"] = "move_cursor_down",
                            ["<C-n>"] = "move_cursor_down",
                            ["<up>"] = "move_cursor_up",
                            ["<C-p>"] = "move_cursor_up",
                            ["<esc>"] = "close",
                            ["<S-CR>"] = "close_keep_filter",
                            ["<C-CR>"] = "close_clear_filter",
                            ["<C-w>"] = { "<C-S-w>", raw = true },
                            {
                                n = {
                                    ["j"] = "move_cursor_down",
                                    ["k"] = "move_cursor_up",
                                    ["<S-CR>"] = "close_keep_filter",
                                    ["<C-CR>"] = "close_clear_filter",
                                    ["<esc>"] = "close",
                                }
                            }
                        },
                    },

                    commands = {},
                },
                buffers = {
                    follow_current_file = {
                        enabled = true,
                        leave_dirs_open = false,
                    },
                    group_empty_dirs = true,
                    show_unloaded = true,
                    window = {
                        mappings = {
                            ["d"] = "buffer_delete",
                            ["bd"] = "buffer_delete",
                            ["<bs>"] = "navigate_up",
                            ["."] = "set_root",
                            ["o"] = {
                                "show_help",
                                nowait = false,
                                config = { title = "Order by", prefix_key = "o" },
                            },
                            ["oc"] = { "order_by_created", nowait = false },
                            ["od"] = { "order_by_diagnostics", nowait = false },
                            ["om"] = { "order_by_modified", nowait = false },
                            ["on"] = { "order_by_name", nowait = false },
                            ["os"] = { "order_by_size", nowait = false },
                            ["ot"] = { "order_by_type", nowait = false },
                        },
                    },
                },
                git_status = {
                    window = {
                        position = "float",
                        popup = {
                            position = { col = "50%", row = "50%" },
                            size = {
                                width = "50%",
                                height = "60%",
                            },
                            border = {
                                style = "rounded",
                                highlight = "FloatBorder",
                                text = {
                                    top = " Git Status ",
                                    top_align = "center",
                                },
                            },
                        },
                        mappings = {
                            ["A"] = "git_add_all",
                            ["gu"] = "git_unstage_file",
                            ["gU"] = "git_undo_last_commit",
                            ["ga"] = "git_add_file",
                            ["gr"] = "git_revert_file",
                            ["gc"] = "git_commit",
                            ["gp"] = "git_push",
                            ["gg"] = "git_commit_and_push",
                            ["o"] = {
                                "show_help",
                                nowait = false,
                                config = { title = "Order by", prefix_key = "o" },
                            },
                            ["oc"] = { "order_by_created", nowait = false },
                            ["od"] = { "order_by_diagnostics", nowait = false },
                            ["om"] = { "order_by_modified", nowait = false },
                            ["on"] = { "order_by_name", nowait = false },
                            ["os"] = { "order_by_size", nowait = false },
                            ["ot"] = { "order_by_type", nowait = false },
                        },
                    },
                },
            })
        end,
        keys = {
            {
                "<leader>p",
                function()
                    require("neo-tree.command").execute({ toggle = true, position = "float" })
                end,
                desc = "Toggle Neo-tree float",
            },
        },
    },
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup({
                default = true,
                strict = false,
                color_icons = true,
                override_by_filename = {
                    [".gitignore"] = {
                        icon = "",
                        color = "#f1502f",
                        name = "Gitignore"
                    },
                    ["README.md"] = {
                        icon = "",
                        color = "#519aba",
                        name = "Readme"
                    },
                    ["package.json"] = {
                        icon = "",
                        color = "#e8274b",
                        name = "PackageJson"
                    },
                },
            })
        end,
    }

}
