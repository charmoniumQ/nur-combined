{ config, pkgs, lib, ... }:
let
  cfg = config.my.home.zsh;

  # Have a nice relative path for XDG_CONFIG_HOME, without leading `/`
  relativeXdgConfig =
    let
      noHome = lib.removePrefix config.home.homeDirectory;
      noSlash = lib.removePrefix "/";
    in
    noSlash (noHome config.xdg.configHome);
in
{
  options.my.home.zsh = with lib; {
    enable = my.mkDisableOption "zsh configuration";

    launchTmux = mkEnableOption "auto launch tmux at shell start";

    notify = {
      enable = mkEnableOption "zsh-done notification";

      enableSsh = mkEnableOption "notify through SSH connections";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        zsh-completions
      ];

      programs.zsh = {
        enable = true;
        dotDir = "${relativeXdgConfig}/zsh"; # Don't clutter $HOME
        enableCompletion = true;

        history = {
          size = 500000;
          save = 500000;
          extended = true;
          expireDuplicatesFirst = true;
          ignoreSpace = true;
          ignoreDups = true;
          share = false;
          path = "${config.xdg.dataHome}/zsh/zsh_history";
        };

        plugins = [
          {
            name = "fast-syntax-highlighting";
            file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
            src = pkgs.zsh-fast-syntax-highlighting;
          }
          {
            name = "agkozak-zsh-prompt";
            file = "share/zsh/site-functions/agkozak-zsh-prompt.plugin.zsh";
            src = pkgs.agkozak-zsh-prompt;
          }
        ];

        # Modal editing is life, but CLI benefits from emacs gymnastics
        defaultKeymap = "emacs";

        # Make those happen early to avoid doing double the work
        initExtraFirst = lib.mkBefore ''
          ${
            lib.optionalString cfg.launchTmux ''
              # Launch tmux unless already inside one
              if [ -z "$TMUX" ]; then
                exec tmux new-session
              fi
            ''
          }
        '';

        initExtra = lib.mkAfter ''
          source ${./completion-styles.zsh}
          source ${./extra-mappings.zsh}
          source ${./options.zsh}

          # Source local configuration
          if [ -f "$ZDOTDIR/zshrc.local" ]; then
            source "$ZDOTDIR/zshrc.local"
          fi
        '';

        localVariables = {
          # I like having the full path
          AGKOZAK_PROMPT_DIRTRIM = 0;
          # Because I *am* from EPITA
          AGKOZAK_PROMPT_CHAR = [ "42sh$" "42sh#" ":" ];
          # Easy on the eyes
          AGKOZAK_COLORS_BRANCH_STATUS = "magenta";
          # I don't like moving my eyes
          AGKOZAK_LEFT_PROMPT_ONLY = 1;
        };

        # Enable VTE integration
        enableVteIntegration = true;
      };
    }

    (lib.mkIf cfg.notify.enable {
      programs.zsh = {
        plugins = [
          {
            name = "zsh-done";
            file = "share/zsh/site-functions/done.plugin.zsh";
            src = pkgs.ambroisie.zsh-done;
          }
        ];

        localVariables = {
          # Enable `zsh-done` through SSH, if configured
          DONE_ALLOW_NONGRAPHICAL = lib.mkIf cfg.notify.enableSsh 1;
        };

        # Use OSC-777 to send the notification through SSH
        initExtra = lib.mkIf cfg.notify.enableSsh ''
          done_send_notification() {
            local exit_status="$1"
            local title="$2"
            local message="$3"

            ${lib.getExe pkgs.ambroisie.osc777} "$title" "$message"
          }
        '';
      };
    })
  ]);
}
