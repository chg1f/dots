-- encoding=utf-8

-- TODO: lua format string ' to "

local function get_prog(name, opts)
  opts = opts or { "$HOME/.local/bin", "/usr/local/bin", "/usr/local/bin", "bin" }
  for _, path in ipairs(opts) do
    path = vim.fn.expand(path)
    if vim.fn.executable(path .. "/" .. name) == 1 then
      return path .. "/" .. name
    end
  end
end

vim.g.python3_host_prog = get_prog("python3")
vim.g.node_host_prog = get_prog("neovim-node-host")

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.notify("Cloning folke/lazy.nvim into " .. lazypath, vim.log.levels.WARN)
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end
vim.opt.rtp:prepend(lazypath)


local plugins = {}

-- colorscheme
vim.list_extend(plugins, {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
  "catppuccin/nvim",
})

-- display
vim.list_extend(plugins, {
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require("lualine").setup({
        options = {
          component_separators = "",
          section_separators = "",
          -- TODO: :help lualine-General-component-options
        },
        extensions = { 'quickfix', 'mason', 'lazy', 'trouble', 'fzf', 'man' },
        tabline = {
          lualine_a = {
            {
              'tabs',
              max_length = vim.o.columns * 2 / 3,
              symbols = { modified = '+' },
            },
          },
          lualine_b = {
            -- TODO: add todo-comments count
          },
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        winbar = {
          lualine_a = {},
          lualine_b = {
            {
              'diagnostics',
              symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
              sources = { 'nvim_lsp', 'nvim_diagnostic' },
            },
          },
          lualine_c = {
            {
              'filename',
              path = 3, -- Absolute path, with tilde as the home directory
              shorting_target = 40,
              symbols = { modified = '*', readonly = '!', unnamed = '%', newfile = '+' },
            }
          },
          lualine_x = { 'diff' },
          lualine_y = { 'branch' },
          lualine_z = {},
        },
        inactive_winbar = {
          lualine_a = {},
          lualine_b = {
            {
              'diagnostics',
              symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
              sources = { 'nvim_lsp', 'nvim_diagnostic' },
            },
          },
          lualine_c = {
            {
              'filename',
              path = 3, -- Absolute path, with tilde as the home directory
              shorting_target = 40,
              symbols = { modified = '*', readonly = '!', unnamed = '%', newfile = '+' },
            }
          },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'filetype', },
          lualine_c = { 'progress', 'location', 'searchcount', 'selectioncount' },
          lualine_x = { 'filesize', },
          lualine_y = { 'encoding', },
          lualine_z = {
            {
              'fileformat',
              symbols = { unix = 'LF', dos = 'CRLF', mac = 'CR' },
            },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'progress', 'location', 'searchcount', 'selectioncount' },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      {
        "rcarriga/nvim-notify",
        keys = {
          { "<leader>un", function() require("notify").dismiss({ silent = true, pending = true }) end, desc = "Dismiss All Notifications", },
        },
        config = function()
          ---@diagnostic disable-next-line: missing-fields
          require("notify").setup({
            stages = "static",
            timeout = 1500,
            icons = {
              ERROR = "",
              WARN = "",
              INFO = "",
              DEBUG = "",
              TRACE = "",
            },
            max_height = function()
              return math.floor(vim.o.lines * 0.5)
            end,
            -- TODO: wrap messages
            max_width = function()
              return math.floor(vim.o.columns * 0.3)
            end,
            on_open = function(win)
              vim.api.nvim_win_set_config(win, { zindex = 100 })
            end,
          })
        end,
      },
    },
    event = "VeryLazy",
    config = function()
      require("noice").setup({ -- spellchecker:disable-line
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true,         -- use a classic bottom cmdline for search
          command_palette = true,       -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false,           -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false,       -- add a border to hover docs and signature help
        },

        views = {
          cmdline_popup = {
            position = { row = "50%", col = "50%", },
          },
          cmdline_popupmenu = {
            relative = "editor",
            position = "auto",
          },
        },
      })
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    event = "VeryLazy",
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          change = { text = '~' },
          changedelete = { text = '~' },
        },
      })
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end,                                             desc = "Next Todo Comment" },
      { "[t",         function() require("todo-comments").jump_prev() end,                                             desc = "Previous Todo Comment" },
      { "<leader>ft", function() require('telescope').extensions["todo-comments"].todo({ keywords = "TODO,BUG" }) end, desc = "Find Todo Comments" },
      -- TODO: jump with diagnostics?
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("todo-comments").setup({
        keywords = {
          TODO = { icon = " ", },
          TEST = { icon = "󰐋 ", },
          FIX = { icon = " ", },
          WARN = { icon = " ", },
          HACK = { icon = " ", },
          PERF = { icon = "󰦖 ", color = "hint" },
          NOTE = { icon = "󰙏 ", },
        }
      })
    end,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<C-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
    config = function()
      require("flash").setup({
        label = { style = "inline", before = { 0, 0 }, after = false },
        modes = {
          search = { enabled = false },
        },
      })
    end
  },
  {
    'folke/which-key.nvim',
    event = "VeryLazy",
    enable = false,
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    keys = {
      { "<leader><leader>", function() require("telescope.builtin").resume() end,                                           desc = "Resume" },
      { "<leader>t",        function() require("telescope.builtin").builtin() end,                                          desc = "Telescope", },
      { "<leader>:",        function() require("telescope.builtin").commands() end,                                         desc = "Commands" },
      { "<leader>\"",       function() require("telescope.builtin").registers() end,                                        desc = "Registers" },
      { "<leader>'",        function() require("telescope.builtin").marks({ mark_type = "all" }) end,                       desc = "Marks" }, -- TODO: marks with sign, https://github.com/LazyVim/LazyVim/commit/bd2ac542a0bb4c58237cd6ca8848063bd20a5282
      { "<leader>/",        function() require("telescope.builtin").current_buffer_fuzzy_find() end,                        desc = "Search" },

      { "<leader>fb",       function() require("telescope.builtin").buffers({ sort_mru = true, sort_lastused = true }) end, desc = "Find Buffers" },
      { "<leader>fd",       function() require("telescope.builtin").diagnostics() end,                                      desc = "Find Diagnostics" },
      { "<leader>ff",       function() require("telescope.builtin").find_files() end,                                       desc = "Find Files" },
      { "<leader>fo",       function() require("telescope.builtin").oldfiles() end,                                         desc = "Find Recent Files" }, -- spellchecker:disable-line
      { "<leader>fg",       function() require("telescope.builtin").live_grep() end,                                        desc = "Find Grep" },
      { "<leader>fs",       function() require("telescope.builtin").git_status() end,                                       desc = "Find Git Status" },
      { "<leader>fc",       function() require("telescope.builtin").git_bcommits() end,                                     desc = "Find Current Buffer Git Commits" },
    },
    dependencies = {
      "nvim-telescope/telescope-ui-select.nvim",
      'nvim-tree/nvim-web-devicons',
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
        build = "make",
      },
    },
    config = function()
      local telescope = require("telescope")
      -- TODO: telescope.nvim default settings, https://github.com/neovim/nvim-lspconfig/issues/320
      -- TODO: telescope.nvim diagnostics result muplitline, https://github.com/nvim-telescope/telescope.nvim/issues/701
      telescope.setup({
        defaults = {
          path_display = {
            -- shorten = { len = 1, exclude = { 1, -2, -1 } }
          },
          mappings = {
            i = {
              ["<C-h>"] = "which_key",
              ["<C-s>"] = function(prompt_bufnr)
                require("flash").jump({
                  pattern = "^",
                  search = {
                    mode = "search",
                    exclude = {
                      function(win)
                        return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
                      end,
                    },
                  },
                  action = function(match)
                    local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
                    picker:set_selection(match.pos[1] - 1)
                  end,
                })
              end,
              ["<C-r>"] = require("trouble.providers.telescope").open_with_trouble,
            },
          },
        },
        pickers = {
          builtin = {
            include_extensions = true,
            use_default_opts = true,
          },
          colorscheme = {
            enable_preview = true,
          },
          find_files = {
            hidden = true,
            no_ignore = true,
            no_ignore_parent = true,
            mappings = {
              i = {
                -- TODO: all buildin go to parent directory, https://github.com/nvim-telescope/telescope.nvim/issues/2179
                ["<C-g>"] = function(prompt_bufnr)
                  local current_picker =
                      require("telescope.actions.state").get_current_picker(prompt_bufnr)

                  local cwd = current_picker.cwd and tostring(current_picker.cwd)
                      or vim.loop.cwd()
                  local parent_dir = vim.fs.dirname(cwd)

                  require("telescope.actions").close(prompt_bufnr)
                  require("telescope.builtin").find_files {
                    prompt_title = vim.fs.basename(parent_dir),
                    cwd = parent_dir,
                  }
                end,
              },
            },
          },
          lsp_definitions = {
            jump_type = "vsplit",
          },
          lsp_references = {
            jump_type = "vsplit",
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({})
          },
        }
      })
      telescope.load_extension("fzf")
      telescope.load_extension("noice") -- spellchecker:disable-line
      telescope.load_extension("notify")
      telescope.load_extension("todo-comments")
      telescope.load_extension("ui-select")
    end
  },
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    keys = {
      { "]r", function() require("trouble").next({ skip_groups = true, jump = true }) end,     desc = "Next Trouble Item" },
      { "[r", function() require("trouble").previous({ skip_groups = true, jump = true }) end, desc = "Previous Trouble Item" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup({})
    end
  },
})

-- coding
vim.list_extend(plugins, {
  -- TODO: clear plugin
  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- LSP toolkit manager
      {
        "williamboman/mason.nvim",
        cmd = { "Mason" },
        build = ":MasonUpdate",
        config = function()
          require("mason").setup({
            install_root_dir = vim.fn.stdpath("data") .. "/mason",
          })
        end,
      },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'creativenull/efmls-configs-nvim',
      {
        "fatih/vim-go",
        build = ":GoUpdateBinaries",
        config = function()
          -- NOTE: Reference https://github.com/fatih/dotfiles/blob/main/init.lua
          -- NOTE: Disable most of the features because treesitter and nvim-lsp take care of it
          vim.g.go_gopls_enabled = 0
          vim.g.go_code_completion_enabled = 0
          vim.g.go_fmt_autosave = 0
          vim.g.go_imports_autosave = 0
          vim.g.go_mod_fmt_autosave = 0
          vim.g.go_doc_keywordprg_enabled = 0
          vim.g.go_def_mapping_enabled = 0
          vim.g.go_textobj_enabled = 0
          vim.g.go_list_type = 'quickfix'
        end,
      },
      -- LSP formatter plugin
      {
        'stevearc/conform.nvim',
        config = function()
          require("conform").setup({
            notify_on_error = true,
            format_on_save = {
              timeout_ms = 500,
            },
          })
        end,
      },
      -- LSP completion plugin
      "hrsh7th/cmp-nvim-lsp",
      --  Useful status updates for LSP
      "folke/noice.nvim",
      -- Neovim development helper
      {
        "folke/neodev.nvim",
        cond = function()
          local _, count = vim.fn.expand("%:p"):gsub("**/nvim/*.lua", "")
          return count > 0
        end,
        config = function() require("neodev").setup({}) end,
      },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
        callback = function(event)
          vim.keymap.set({ 'n' }, '<leader>d',
            function() require("telescope.builtin").diagnostics() end,
            { desc = "Diagnostics" })
          -- vim.keymap.set({ 'n' }, '<leader>d',
          --   function() require("trouble").open({ mode = "document_diagnostics" }) end,
          --   { desc = "Document Diagnostics" })
          -- vim.keymap.set({ 'n' }, '<leader>D',
          --   function() require("trouble").open({ mode = "workspace_diagnostics" }) end,
          --   { desc = "Workspace Diagnostics" })
          vim.keymap.set({ 'n' }, ']d', vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
          vim.keymap.set({ 'n' }, '[d', vim.diagnostic.goto_prev, { desc = "Previous Document Diagnostic" })

          vim.keymap.set('n', 'K', vim.lsp.buf.hover,
            { buffer = event.buf, desc = 'Hover LSP Documentation' })
          vim.keymap.set({ 'n', 'i' }, '<C-k>', vim.lsp.buf.signature_help,
            { buffer = event.buf, desc = 'LSP Signature Help' })

          vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions,
            { buffer = event.buf, desc = "Goto LSP Definition" })
          vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references,
            { buffer = event.buf, desc = "Goto LSP References" })
          vim.keymap.set('n', 'gI', require('telescope.builtin').lsp_implementations,
            { buffer = event.buf, desc = "Goto LSP Implementation" })
          vim.keymap.set('n', 'gD', require('telescope.builtin').lsp_type_definitions,
            { buffer = event.buf, desc = "Goto LSP Type Definition" })

          vim.keymap.set('n', '<leader>fw', require('telescope.builtin').lsp_dynamic_workspace_symbols,
            { buffer = event.buf, desc = "Find LSP Workspace Symbols" })

          vim.keymap.set('n', '<leader>cf', function() require('conform').format({ lsp_fallback = true }) end,
            { buffer = event.buf, desc = "Format LSP Document" })
          vim.keymap.set('n', '<leader>cn', vim.lsp.buf.rename,
            { buffer = event.buf, desc = "Rename LSP Symbol" })
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action,
            { buffer = event.buf, desc = "LSP Code Action" })
          vim.keymap.set('n', '<leader>cl', vim.lsp.codelens.run,
            { buffer = event.buf, desc = "Run LSP Code Lens" })
          vim.keymap.set('n', '<leader>cL', vim.lsp.codelens.refresh,
            { buffer = event.buf, desc = "Refresh LSP Code Lens" })

          -- TODO: workspace folder configuration
          vim.keymap.set('n', '<leader>wl', function() vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
            { desc = "List LSP Workspace Folders" })
          vim.keymap.set('n', '<leader>wr', function() vim.lsp.buf.remove_workspace_folder() end,
            { desc = "Remove LSP Workspace Folder" })
          vim.keymap.set('n', '<leader>wa', function() vim.lsp.buf.add_workspace_folder() end,
            { desc = "Add LSP Workspace Folder" })

          vim.fn.sign_define("DiagnosticSignError", { text = "󰬌 ", texthl = "DiagnosticError" })
          vim.fn.sign_define("DiagnosticSignWarn", { text = "󰬞 ", texthl = "DiagnosticWarn" })
          vim.fn.sign_define("DiagnosticSignInfo", { text = "󰬐 ", texthl = "DiagnosticInfo" })
          vim.fn.sign_define("DiagnosticSignHint", { text = "󰬏 ", texthl = "DiagnosticHint" })

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client then
            if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
              vim.keymap.set('n', '<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
              end, { buffer = event.buf, desc = 'Toggle LSP Inlay Hints' })
            end

            -- The following two autocommands are used to highlight references of the
            -- word under your cursor when your cursor rests there for a little while.
            --    See `:help CursorHold` for information about when this is executed
            --
            -- When you move your cursor, the highlights will be cleared (the second autocommand).
            if client.server_capabilities.documentHighlightProvider then
              local highlight_augroup = vim.api.nvim_create_augroup('UserLspHighlight', { clear = false })
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
              })
              vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
              })
              vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('UserLspDetach', { clear = true }),
                callback = function(event2)
                  vim.lsp.buf.clear_references()
                  vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                end,
              })
            end
          end
        end,
      })

      local efmls_loglevel = {
        [vim.log.levels.TRACE] = "5",
        [vim.log.levels.DEBUG] = "4",
        [vim.log.levels.INFO] = "3",
        [vim.log.levels.WARN] = "2",
        [vim.log.levels.ERROR] = "1",
        [vim.log.levels.OFF] = "0",
      }
      local efmls_modules = {
        {
          { 'vint' },
          ft = { 'vim' },
          settings = {
            require('efmls-configs.linters.vint'),
          },
        },
        {
          { 'shfmt', 'shellcheck' },
          ft = { "sh", "bash", "zsh" },
          settings = {
            require('efmls-configs.linters.shellcheck'),
            require('efmls-configs.formatters.shfmt'),
          },
        },
      }
      local ensure_installed = {}
      local efmls_languages = {}
      for _, module in pairs(efmls_modules) do
        ensure_installed = vim.list_extend(ensure_installed, module[1])
        for _, ft in pairs(module.ft) do
          efmls_languages[ft] = vim.tbl_extend("force", efmls_languages[ft] or {}, module.settings or {})
        end
      end
      require('mason-tool-installer').setup({
        ensure_installed = ensure_installed,
        run_on_start = true,
      })
      local modules = {
        -- general
        typos_lsp = {
          init_options = {
            diagnosticSeverity = "Hint"
          },
        },
        ast_grep = {},

        efm = {
          cmd = { "efm-langserver", "--logfile", vim.fn.stdpath("state") .. "/efm.log", "--loglevel", efmls_loglevel[require("vim.lsp.log").get_level()] },
          init_options = {
            documentFormatting = true,
            documentRangeFormatting = true,
            hover = true,
            documentSymbol = true,
            codeAction = true,
            completion = true,
          },
          settings = {
            rootMarkers = { ".git/" },
            filetype = vim.tbl_keys(efmls_languages),
            languages = efmls_languages,
          }
        },

        -- javascript/typescript
        eslint = {},
        tsserver = {},

        -- golang
        gopls = {
          -- NOTE: Reference https://github.com/fatih/dotfiles/blob/main/init.lua
          flags = { debounce_text_changes = 200 },
          settings = {
            gopls = {
              usePlaceholders = true,
              gofumpt = true,
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              experimentalPostfixCompletions = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = {
                "-**/.git",
                "-**/node_modules",
                "-**/.gvm", -- BUG: unavailable
              },
              semanticTokens = true,
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },

        -- python
        ruff = {},

        -- lua
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      }
      require('mason-lspconfig').setup({
        ensure_installed = vim.tbl_keys(modules or {}),
        automatic_installation = true,
        handlers = {
          function(name)
            require('lspconfig')[name].setup(
              vim.tbl_deep_extend('force',
                {
                  capabilities = vim.tbl_deep_extend('force',
                    vim.lsp.protocol.make_client_capabilities() or {},
                    require('cmp_nvim_lsp').default_capabilities() or {}
                  )
                },
                modules[name] or {}
              )
            )
          end,
        },
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    version = nil,
    dependencies = {
      {
        "zbirenbaum/copilot-cmp",
        dependencies = {
          {
            "zbirenbaum/copilot.lua",
            build = function()
              vim.cmd([[Copilot auth]])
            end,
            config = function()
              require("copilot").setup({ copilot_node_command = get_prog("node") })
            end
          },
        },
        config = function()
          require("copilot_cmp").setup({})
        end
      },
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        build = "make install_jsregexp"
      },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-cmdline" },
      { "lukas-reineke/cmp-under-comparator" }, -- better sort completion items that start with one or more underlines.
      { "hrsh7th/cmp-nvim-lua" },               -- TODO: remove?
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        preselect = cmp.PreselectMode.None,
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<C-n>'] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_next_item(); return
            end

            local luasnip = require("luasnip")
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump(); return
            end

            cmp.complete()
            -- local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            -- if col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil then
            --   cmp.complete(); return
            -- end

            -- if opts.use_fallback then
            --   fallback(); return
            -- end
          end, { 'i', 's' }),
          ['<C-p>'] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item(); return
            end

            local luasnip = require("luasnip")
            if luasnip.jumpable(-1) then
              luasnip.jump(-1); return
            end

            -- if opts.use_fallback then
            --   fallback(); return
            -- end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'copilot' },
          { name = "luasnip" },
        }, {
          { name = 'buffer', },
          { name = 'path', },
          -- { name = 'nvim_lua' }, -- for neovim Lua API.
        })
      })

      -- -- Set configuration for specific filetype.
      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'copilot' },
        }, {
          { name = 'buffer' },
        })
      })

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'copilot' },
        },
        {
          { name = 'buffer' },
        }
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'copilot' },
          { name = 'path' }
        }, {
          { name = 'cmdline' },
          { name = 'buffer' }
        })
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VimEnter",
    keys = {
      { "gp", function() require("treesitter-context").go_to_context(vim.v.count or 1) end, desc = "Goto Previous Context" },
      -- { "gn", function() require("treesitter-context").go_to_context(-vim.v.count or -1) end, desc="Goto Next Context"},
    },
    build = ":TSUpdate",
    init = function(plugin)
      -- HACK: add nvim-treesitter to the rtp early during startup
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc', 'json' },
        auto_install = true,

        highlight = {
          enable = true,
          disable = function(_, buf)
            local max_filesize = 500 * 1024 -- 500MiB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },
        indent = { enable = true },
        incremental_selection = { enable = true },

      })
      -- BUG: after formatting, the folding is broken
      -- vim.opt.foldmethod = 'expr'
      -- vim.opt.foldexpr   = 'nvim_treesitter#foldexpr()'
      require("treesitter-context").setup({
        { mode = "cursor", max_lines = 3 },
      })
    end,
  },
  {
    'numToStr/Comment.nvim',
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Toggle Comment Line" },
      { "gb", mode = { "n", "v" }, desc = "Toggle Comment Block" },
    },
    config = function()
      ---@diagnostic disable-next-line:missing-fields
      require('Comment').setup()
    end
  },
  {
    "mfussenegger/nvim-dap",
  },
})

-- TODO: plugins
vim.list_extend(plugins, {
  {
    "echasnovski/mini.nvim"
  },
})

require("lazy").setup(plugins,
  {
    -- directory where plugins will be installed
    root = vim.fn.stdpath("data") .. "/lazy",
    -- lockfile generated after running update.
    lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
    defaults = {
      -- plugins lazy loaded by default
      lazy = true,
    },
    install = {
      -- try to load one of these colorschemes when starting an installation during startup
      colorscheme = { "tokyonight" },
    },
    checker = {
      -- automatically check for plugin updates
      enabled = true,
      frequency = 86400, -- check for updates every day
    },
  }
)
