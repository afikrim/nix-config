return {
  -- === Debugging ============================================================
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        config = function()
          require("dapui").setup()
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "DAP Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "DAP Step Into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "DAP Step Over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "DAP Step Out" },
      { "<leader>dq", function() require("dap").terminate() end, desc = "DAP Terminate" },
      { "<leader>dr", function() require("dap").restart() end, desc = "DAP Restart" },
      { "<leader>du", function() require("dapui").toggle({ reset = true }) end, desc = "DAP Toggle UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "DAP Eval Expression", mode = { "n", "v" } },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "python", "codelldb", "js", "node2" },
      handlers = {},
      automatic_installation = true,
    },
  },

  -- === Git tooling ==========================================================
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.current_line_blame = true
      opts.current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 300,
      }
      opts.current_line_blame_formatter = " <author>, <author_time:%R> • <summary>"
      return opts
    end,
    keys = {
      { "<leader>ub", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle Inline Git Blame" },
    },
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "GBrowse" },
    keys = {
      { "<leader>gg", "<cmd>Git<cr>", desc = "Fugitive Status" },
      { "<leader>gp", "<cmd>Git push<cr>", desc = "Git Push" },
      { "<leader>gl", "<cmd>Git pull<cr>", desc = "Git Pull" },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewFileHistory",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git Diff (Diffview)" },
      { "<leader>gD", "<cmd>DiffviewFileHistory %<cr>", desc = "Git File History" },
    },
    opts = {},
  },
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    init = function()
      vim.g.gitblame_enabled = 0
      vim.g.gitblame_display_virtual_text = 0
      vim.g.gitblame_date_format = "%Y-%m-%d %H:%M"
    end,
    keys = {
      { "<leader>gB", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git Blame Popup" },
      { "<leader>gL", "<cmd>GitBlameOpenCommitURL<cr>", desc = "Open Commit in Browser" },
    },
  },

  -- === Copilot ==============================================================
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "zbirenbaum/copilot-cmp" },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, 1, { name = "copilot", group_index = 2 })
    end,
  },

  -- === Coding agent / Avante ================================================
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante" },
    opts = {
      file_types = { "markdown", "Avante" },
    },
  },
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        prompt_for_file_name = false,
        drag_and_drop = {
          insert_mode = true,
        },
        use_absolute_path = true,
      },
    },
  },
  {
    "yetone/avante.nvim",
    build = "make",
    event = "VeryLazy",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      "stevearc/dressing.nvim",
      "folke/snacks.nvim",
      "MeanderingProgrammer/render-markdown.nvim",
      "HakonHarnes/img-clip.nvim",
    },
    opts = {
      provider = "copilot",
      instructions_file = "avante.md",
      auto_suggestions = true,
      mappings = {
        ask = "<leader>aa",
        edit = "<leader>ae",
        refresh = "<leader>ar",
        toggle = "<leader>aA",
      },
      hints = { enabled = true },
    },
    keys = {
      { "<leader>aa", function() require("avante.api").ask() end, desc = "Avante Ask" },
      { "<leader>ae", function() require("avante.api").edit() end, desc = "Avante Edit" },
      { "<leader>aA", function() require("avante.api").toggle() end, desc = "Toggle Avante Panel" },
      { "<leader>az", function() require("avante.api").zen_mode() end, desc = "Avante Zen Mode" },
    },
  },
}
