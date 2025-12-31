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
  ];

  # Shell
  programs.zsh = {
    enable = true;
    shellAliases = {
      hms = "nix run home-manager -- switch --flake ~/.config/home-manager";
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

      -- Auto-format on save
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
