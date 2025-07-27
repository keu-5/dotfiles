return {
    -- プラグインのインストール先
    root = vim.fn.stdpath("data") .. "/lazy",

    -- 起動時の設定
    defaults = {
        lazy = false, -- デフォルトでは起動時にロード
        version = "*", -- 可能な限り最新の安定版を使用
    },

    -- UI設定
    ui = {
        border = "rounded",
        icons = {
            cmd = "⌘",
            config = "🛠",
            event = "📅",
            ft = "📂",
            init = "⚙",
            keys = "🗝",
            plugin = "🔌",
            runtime = "💻",
            source = "📄",
            start = "🚀",
            task = "📋",
            lazy = "💤",
        },
    },

    -- インストール設定
    install = {
        missing = true,                        -- 不足しているプラグインを自動インストール
        colorscheme = { "catppuccin", "habamax" }, -- フォールバック付きカラースキーム
    },

    -- 自動更新チェック
    checker = {
        enabled = true,
        notify = false, -- 通知を無効化（うるさいため）
        frequency = 3600, -- 1時間ごとにチェック
    },

    -- 変更検知
    change_detection = {
        enabled = true,
        notify = false, -- 通知を無効化
    },

    -- パフォーマンス最適化
    performance = {
        cache = {
            enabled = true,
        },
        reset_packpath = true,
        rtp = {
            reset = true,
            paths = {},
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
}
