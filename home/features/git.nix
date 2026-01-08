{...}: {
  programs = {
    git = {
      enable = true;
      settings = {
        alias = {
          a = "add";
          c = "commit";
          ca = "commit --amend";
          f = "fixup";
          fa = "fetch --all";
          fixup = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o -I % sh -c 'git commit --fixup % && git rebase -i %^'";
          l = ''log --pretty=format:"%h - %an:%x09%s"'';
          pf = "push --force";
          ra = "rebase --abort";
          rc = "rebase --continue";
          ri = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o -I % sh -c 'git rebase -i %^'";
          s = "status";
          prune-local = "!git fetch -p && git for-each-ref --format=\"%(refname:short) %(upstream:track)\" refs/heads | awk '$2 ~ /\\[gone\\]/ {print $1}' | xargs -r git branch -d";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push = {autoSetupRemote = true;};
        rebase = {autosquash = true;};
        rerere = {enabled = true;};
        fetch.prune = true;
      };
    };

    lazygit = {
      enable = true;
      settings = {
        git = {
          overrideGpg = true;
        };
      };
    };
  };
}
