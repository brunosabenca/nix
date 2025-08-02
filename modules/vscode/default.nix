{
  inputs,
  pkgs,
  home-manager,
  username,
  ...
}: {
  home-manager.users.${username} = 
    {
      pkgs,
      ...
    }: {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode.fhsWithPackages (ps: with ps; [
          # add extension-specific dependencies here
      ]);
    };
  };
}
