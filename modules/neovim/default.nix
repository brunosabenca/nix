{
  username,
  ...
}:
{
  home-manager.users.${username} = {
    config.nixCats = {
      enable = true;
      packageNames = [
        "nixCats"
        "regularCats"
      ];
    };
  };
}
