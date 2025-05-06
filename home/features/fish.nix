{ pkgs, ... }: {
  # Enable Fish shell in home-manager
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Set fish greeting to empty
      set fish_greeting
    '';
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -la";
      ".." = "cd ..";
      os-update = "nh os switch -u -a";
    };
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ "$TERM_PROGRAM" != "vscode" && $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
}
