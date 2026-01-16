return {
    -- LSP Configuration & Plugins
    {
        "neovim/nvim-lspconfig",
        version = "v0.1.8", -- 安定版に固定
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            -- 自動的にLSPサーバーをインストール
            { "williamboman/mason.nvim",           version = "v1.10.0" },
            { "williamboman/mason-lspconfig.nvim", version = "v1.29.0" },

            -- 補完統合（依存関係として追加）
            "hrsh7th/cmp-nvim-lsp",

            -- 追加のlua設定
            { "folke/neodev.nvim", version = "v3.0.0" },
        },
        config = function()
            -- 先にmasonをセットアップ
            require("mason").setup({
                ui = {
                    border = "rounded",
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })

            -- 自動的にインストールするLSPサーバー
            local servers = {
                lua_ls = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                        diagnostics = { disable = { 'missing-fields' } },
                    },
                },
                -- TypeScript/JavaScript (Next.js対応)
                tsserver = {},
                -- HTML
                html = {},
                -- CSS/Tailwind CSS
                cssls = {},
                tailwindcss = {},
                -- Python
                pyright = {},
                -- Go
                gopls = {},
                -- Ruby
                ruby_lsp = {},
                -- Docker
                dockerls = {},
                docker_compose_language_service = {},
                -- YAML
                yamlls = {},
                -- JSON
                jsonls = {},
            }

            -- mason-lspconfig の設定（masonの後にセットアップ）
            local has_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
            if not has_mason_lspconfig then
                vim.notify("mason-lspconfig not found", vim.log.levels.ERROR)
                return
            end

            mason_lspconfig.setup({
                ensure_installed = vim.tbl_keys(servers),
                automatic_installation = true,
            })

            -- neodevの設定（lua LSPの改善）
            local has_neodev, neodev = pcall(require, "neodev")
            if has_neodev then
                neodev.setup()
            end

            -- LSPサーバーの起動時に実行される関数
            local on_attach = function(client, bufnr)
                local nmap = function(keys, func, desc)
                    if desc then
                        desc = "LSP: " .. desc
                    end
                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
                end

                nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
                nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

                -- Telescopeが利用可能な場合のみ使用
                local has_telescope, builtin = pcall(require, "telescope.builtin")
                if has_telescope then
                    nmap("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
                    nmap("gr", builtin.lsp_references, "[G]oto [R]eferences")
                    nmap("gI", builtin.lsp_implementations, "[G]oto [I]mplementation")
                    nmap("<leader>D", builtin.lsp_type_definitions, "Type [D]efinition")
                    nmap("<leader>ds", builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
                    nmap("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
                else
                    -- Telescopeがない場合はネイティブLSP機能を使用
                    nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
                    nmap("gr", vim.lsp.buf.references, "[G]oto [R]eferences")
                    nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
                    nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
                end

                nmap("K", vim.lsp.buf.hover, "Hover Documentation")
                nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

                nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
                nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
                nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
                nmap("<leader>wl", function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, "[W]orkspace [L]ist Folders")

                -- フォーマット
                nmap("<leader>f", function()
                    vim.lsp.buf.format({ async = true })
                end, "[F]ormat")

                -- ドキュメントハイライト
                if client.server_capabilities.documentHighlightProvider then
                    local highlight_augroup = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
                    vim.api.nvim_clear_autocmds({ buffer = bufnr, group = highlight_augroup })
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = bufnr,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })
                    vim.api.nvim_create_autocmd("CursorMoved", {
                        buffer = bufnr,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })
                end
            end

            -- nvim-cmp の capabilities
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            if has_cmp then
                capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
            end

            -- LSPサーバーの設定
            -- setup_handlersの存在確認とフォールバック処理
            if mason_lspconfig.setup_handlers then
                mason_lspconfig.setup_handlers({
                    -- デフォルトハンドラー
                    function(server_name)
                        local has_lspconfig, lspconfig = pcall(require, "lspconfig")
                        if has_lspconfig and lspconfig[server_name] then
                            lspconfig[server_name].setup({
                                capabilities = capabilities,
                                on_attach = on_attach,
                                settings = servers[server_name],
                                filetypes = (servers[server_name] or {}).filetypes,
                            })
                        end
                    end,
                })
            else
                -- フォールバック：手動でLSPサーバーを設定
                local has_lspconfig, lspconfig = pcall(require, "lspconfig")
                if has_lspconfig then
                    for server_name, _ in pairs(servers) do
                        if lspconfig[server_name] then
                            lspconfig[server_name].setup({
                                capabilities = capabilities,
                                on_attach = on_attach,
                                settings = servers[server_name],
                                filetypes = (servers[server_name] or {}).filetypes,
                            })
                        end
                    end
                end
            end

            -- 診断の設定
            vim.diagnostic.config({
                virtual_text = {
                    prefix = "●",
                },
                signs = true,
                update_in_insert = false,
                underline = true,
                severity_sort = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })

            -- 診断アイコンの設定
            local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

            -- 診断のキーマップ
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "前の診断へ" })
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "次の診断へ" })
            vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "診断を表示" })
            vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "診断をloclistに" })
        end,
    },
}
