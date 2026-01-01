{ config, pkgs, ... }:

{
  home.username = "juliusvolland";
  home.homeDirectory = "/Users/juliusvolland";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # Packages
  home.packages = with pkgs; [
    ripgrep
    fd
    d2
    nixfmt-rfc-style
    pixi
    basedpyright
    ruff
  ];

  # Shell
  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    shellAliases = {
      hms = "nix run home-manager -- switch --flake ~/.config/home-manager";
      ll = "ls -la";
      glola = "git log --graph --all";
    };
  };

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      render-markdown-nvim
      conform-nvim

      # d2-vim from GitHub
      (pkgs.vimUtils.buildVimPlugin {
        name = "d2-vim";
        src = pkgs.fetchFromGitHub {
          owner = "terrastruct";
          repo = "d2-vim";
          rev = "cb3eb7fcb1a2d45c4304bf2e91077d787b724a39";
          sha256 = "sha256-HmDQfOIoSV93wqRe7O4FPuHEmAxwoP1+Ut+sKhB62jA=";
        };
      })
    ];

    extraLuaConfig = ''
      require('render-markdown').setup({})

      -- Python LSP (Neovim 0.11+)
      vim.lsp.config('basedpyright', {
        cmd = { 'basedpyright-langserver', '--stdio' },
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'pixi.toml', 'setup.py', '.git' },
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "basic",
            },
          },
        },
      })

      vim.lsp.config('ruff', {
        cmd = { 'ruff', 'server' },
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'pixi.toml', 'ruff.toml', '.git' },
      })

      vim.lsp.enable({ 'basedpyright', 'ruff' })

      -- LSP keymaps
      vim.keymap.set('n', 'gl', vim.diagnostic.open_float)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)

      -- Format on save (LSP for Python, conform for others)
      vim.api.nvim_create_autocmd('BufWritePre', {
        callback = function(args)
          if vim.bo[args.buf].filetype == 'python' then
            vim.lsp.buf.format({ async = false })
          end
        end,
      })

      require('conform').setup({
        formatters_by_ft = {
          nix = { "nixfmt" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      -- Nix files: 2-space indent
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "nix",
        callback = function()
          vim.opt_local.tabstop = 2
          vim.opt_local.shiftwidth = 2
          vim.opt_local.softtabstop = 2
          vim.opt_local.expandtab = true
        end,
      })
    '';
  };
}
