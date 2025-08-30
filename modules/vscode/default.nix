{
  inputs,
  pkgs,
  home-manager,
  username,
  ...
}:  {
  home-manager.users.${username} = 
    {
      pkgs,
      ...
    }: let patched-openssh = pkgs.openssh.overrideAttrs (prev: { patches = (prev.patches or []) ++ [ ./openssh-nocheckcfg.patch ]; }); in {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode.fhsWithPackages (ps: with ps; [
          patched-openssh # https://github.com/nix-community/home-manager/issues/322#issuecomment-1178614454
          # add extension-specific dependencies here
      ]);
    };
  };
}
