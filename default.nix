{
  inputs,
  agenix,
  neovim,
  home-manager,
  pkgs,
  username,
  config,
  system,
  lib,
  ...
}:
{
  imports = [
    # Load agenix and install client package
    agenix.nixosModules.default
    {
      environment.systemPackages = [
        agenix.packages."${system}".default
      ];
    }

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.sharedModules = [
        agenix.homeManagerModules.default
        neovim.homeModules.default
      ];
    }
  ];

  virtualisation.docker.enable = false;

  # Enable nix-ld to use dynamically linked executables with hardcoded paths
  programs.nix-ld.enable = true;

  # Enable envfs for fhs compatibility
  services.envfs.enable = true;

  environment.sessionVariables = {
    EDITOR = "nvim";

    # Hint electron aps to use wayland
    NIXOS_OZONE_WL = "1";

    MOZ_USE_XINPUT2 = "1";
  };

  environment.shellAliases = {
    ls = "exa --icons -F -H --group-directories-first --git -1";
    ll = "ls -alF";
    k = "kubectl";
    n = "nvim";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.htop = {
    enable = true;
    settings.show_cpu_temperature = 1;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [
    50341
    53317 # LocalSend
  ];
  networking.firewall.allowedUDPPorts = [
    50341
    53317 # LocalSend
  ];

  security.polkit.enable = true;
}
