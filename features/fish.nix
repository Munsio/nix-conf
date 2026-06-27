{...}: {
  flake.homeModules.fish = {pkgs, ...}: {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
      shellAliases = {
        check-opencode-update = "curl -s https://api.github.com/repos/Munsio/nix-conf/pulls?head=Munsio:auto/opencode-update&state=open | jq -r 'if .[0] then \"OpenCode update PR: \" + .[0].html_url else \"No pending opencode update.\" end'";
        ls = "ls --color=auto";
        ll = "ls -lah";
        ".." = "cd ..";
        os-update = "nh os switch -u -a";
        hm-switch = "home-manager switch --flake ~/Documents/nix-conf/#(hostname)";
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
  };
}
