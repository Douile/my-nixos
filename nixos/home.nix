{ config, lib, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dev";
  home.homeDirectory = "/home/dev";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "22.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.shellAliases = {
    # Rebuild nixos
    rebuild = "sudo nixos-rebuild switch --flake ~/system-config/#myNixos";
    # Git aliases
    gp = "git push";
    gap = "git add -p";
    gd = "git diff";
    gdc = "git diff --cached";
    gs = "git status";
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dev/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nvim";
    GOPATH = "/src/go-path/";
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Configure git
  programs.git = {
    enable = true;
    userName = "Douile";
    userEmail = "douile@douile.com";
    signing = {
      signByDefault = true;
      key = null;
    };
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  # Configure zsh
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;

    # Configure oh-my-zsh
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "git"
        "sudo"
        "rust"
        "node"
      ];
    };
  };


  # Configure eza
  programs.eza = {
    enable = true;
    enableAliases = true;
  };

  # Configure neovim
  programs.neovim = 
  let
    # Put lua in vimscript variables
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua <<EOF\n${builtins.readFile file}\nEOF\n";

  in
  {
    enable = true;

    # Required extra packages
    extraPackages = with pkgs; [
      lua-language-server
      rnix-lsp
    ];

    # Plugins
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lspconfig;
        config = toLuaFile ./nvim/plugin/lsp.lua;
      }

      {
        plugin = comment-nvim;
        config = toLua "require(\"Comment\").setup()";
      }

      neodev-nvim

      {
        plugin = nvim-cmp;
        config = toLuaFile ./nvim/plugin/cmp.lua;
      }

      {
        plugin = telescope-nvim;
        config = toLuaFile ./nvim/plugin/telescope.lua;
      }

      telescope-fzf-native-nvim

      cmp_luasnip
      cmp-nvim-lsp

      luasnip
      friendly-snippets

      lualine-nvim
      nvim-web-devicons

      {
        plugin = (nvim-treesitter.withPlugins (p: [
          p.tree-sitter-nix
          p.tree-sitter-vim
          p.tree-sitter-bash
          p.tree-sitter-lua
          p.tree-sitter-python
          p.tree-sitter-json
          p.tree-sitter-json5
          p.tree-sitter-c
          p.tree-sitter-cpp
          p.tree-sitter-rust
          p.tree-sitter-javascript
          p.tree-sitter-typescript
          p.tree-sitter-toml
          p.tree-sitter-yaml
          p.tree-sitter-diff
        ]));
        config = toLuaFile ./nvim/plugin/treesitter.lua;
      }

      vim-nix

      {
        plugin = nvim-lastplace;
        config = toLua "require(\"nvim-lastplace\").setup()";
      }
    ];

    # Lua config
    extraLuaConfig = ''
      -- Write lua code here

      -- or iterpolate files like this:

      ${builtins.readFile ./nvim/options.lua}
    '';

    # Aliases
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
