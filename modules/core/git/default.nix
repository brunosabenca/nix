{
  username,
  ...
}:
{
  home-manager.users.${username} = {
    programs.git = {
      enable = true;
      signing = {
        format = "openpgp";
      };
      settings = {
        user = {
          name = "Bruno Sabença";
          email = "bruno@brunosabenca.com";
        };
        format = {
          pretty = "oneline";
        };
        log = {
          decorate = "short";
          abbrevCommit = true;
        };
        init.defaultBranch = "main";
      };
    };
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
