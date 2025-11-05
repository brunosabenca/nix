{
  username,
  ...
}:
{
  home-manager.users.${username} = {
    programs.git = {
      enable = true;
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
      };
    };
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
