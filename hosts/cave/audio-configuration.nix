# Based on https://github.com/joseph-long/pixie/blob/master/nixos/cave-audio.nix
{
  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=4
    options snd-soc-avs ignore_fw_version=1
  '';
}
