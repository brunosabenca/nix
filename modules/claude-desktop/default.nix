{ claude-desktop, username, ... }:
{
  imports = [ claude-desktop.nixosModules.default ];

  programs.claude-desktop = {
    enable = true;
    cowork = {
      enable = true;
      users = [ username ];
    };
  };
}
