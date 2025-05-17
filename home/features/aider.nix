{
  pkgs,
  lib,
  ...
}: {
  # Install Aider package
  home.packages = [pkgs.aider-chat];

  # Configure Aider
  # Creates ~/.aider.conf.yml
  home.file.".aider.conf.yml" = {
    text = lib.generators.toYAML {} {
      model = "gemini"; # Default model, uses the alias below
      alias = [
        "gemini:openrouter/google/gemini-2.5-pro-preview-03-25"
        "claude:openrouter/anthropic/claude-3.7-sonnet"
      ];
    };
  };
}
