{
  inputs,
  home-manager,
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = {
    programs.git = {
      enable = true;
      userName = "Bruno Sabença";
      userEmail = "bruno@brunosabenca.com";
      delta.enable = true;
      extraConfig = {
        format = {
          pretty = "oneline";
        };
        log = {
          decorate = "short";
          abbrevCommit = true;
        };
      };
    };
  };
}
