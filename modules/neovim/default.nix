{
  username,
  ...
}:
{
  home-manager.users.${username} = {
    config.Neovim = {
      enable = true;
      packageNames = [
        "Neovim"
        "regularCats"
      ];
    };
  };
}
