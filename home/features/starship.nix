{lib, ...}: {
  # Enable Starship prompt in home-manager
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      format = lib.concatStrings ["$directory" "$character"];
      right_format = "$all";
      git_branch = {format = "[$symbol$branch(:$remote_branch)]($style) ";};
      nix_shell = {
        symbol = "❄️ ";
        format = "via [$symbol$state( ($name))]($style) ";
      };
      golang = {symbol = " ";};
    };
  };
}
