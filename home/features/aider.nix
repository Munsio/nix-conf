{
  pkgs,
  lib,
  ...
}: {
  # Install Aider package
  home.packages = [pkgs.aider];

  # Configure Aider
  # Creates ~/.aider.conf.yml
  home.file.".aider.conf.yml" = {
    text = lib.generators.toYAML {} {
      model = "gemini"; # Default model, uses the alias below
      auto-aliases = {
        gemini = "openrouter/google/gemini-2.5-pro-preview";
        claude = "openrouter/anthropic/claude-3.7-sonnet";
      };
    };
  };
}
