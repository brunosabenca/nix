{
  claude-desktop,
  username,
  pkgs,
  ...
}:
{
  imports = [ claude-desktop.nixosModules.default ];

  programs.claude-desktop = {
    enable = true;
    # Electron only auto-detects a keyring on desktops it knows (GNOME, KDE, ...).
    # Under niri it falls back to plaintext, so point it at gnome-keyring explicitly.
    package =
      claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop.overrideAttrs
        (old: {
          postFixup = old.postFixup + ''
            wrapProgramShell "$out/bin/claude-desktop" --add-flags "--password-store=gnome-libsecret"
          '';
        });
    cowork = {
      enable = true;
      users = [ username ];
    };
  };
}
