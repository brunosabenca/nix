{ inputs, ... }:
{
  imports = [ inputs.kmonad.nixosModules.default ];

  services.kmonad = {
    enable = true;
    keyboards = {
      myKMonadOutput = {
        device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        config = builtins.readFile ./miryoku.kbd;
      };
    };
  };
}
