# Based on https://github.com/joseph-long/pixie/blob/master/nixos/cave-audio.nix
{
  config,
  pkgs,
  ...
}: let
  # caveAudioFiles = pkgs.fetchzip {
  #   url = "https://github.com/nebulakl/cave-audio/archive/0ac059e243c8663908500ec01d7a11ee116041d9.tar.gz";
  #   sha256 = "0c9bdj96d3d12fyiyh3fiim47b1lhsw1pbqb52ny0sp5wh64dwl5";
  # };
  # crosAudioTopology = pkgs.fetchurl {
  #   url = "https://bugzilla.kernel.org/attachment.cgi?id=282677";
  #   sha256 = "0n3ycx91g98pdias9594jqllvjxwh7ib0w65gpk5siayldqxgaal";
  # };
  # avsTopology = pkgs.fetchurl {
  #   url = "https://github.com/WeirdTreeThing/chromebook-linux-audio/blob/99eef5cc3d2f82f451c34764f230f3d5d22239cf/blobs/avs-topology_2024.02.tar.gz";
  #   sha256 = "";
  # };
in {
  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=4
    options snd-soc-avs ignore_fw_version=1
  '';

  # hardware.enableRedistributableFirmware = true;
  # hardware.firmware = [
  #   (pkgs.runCommandNoCC "firmware-audio-CAVE" {} ''
  #     mkdir -p $out/lib/firmware
  #     cp ${crosAudioTopology} $out/lib/firmware/9d70-CORE-COREBOOT-0-tplg.bin
  #     cp ${crosAudioTopology} $out/lib/firmware/dfw_sst.bin
  #   '')
  #   (pkgs.runCommandNoCC "firmware-audio-CAVE" {} ''
  #     mkdir -p $out/lib/firmware/intel/
  #     cp ${pkgs.firmwareLinuxNonfree}/lib/firmware/intel/dsp_fw_release_v969.bin $out/lib/firmware/intel/dsp_fw_release.bin
  #   '')
  # ];
  # boot.kernelModules = ["skl_n88l25_m98357a" "snd_soc_skl"];

  # # Sound requires custom UCM files and topology bin:
  # system.replaceDependencies.replacements = [
  #   {
  #     oldDependency = pkgs.alsa-lib;
  #     newDependency = pkgs.alsa-lib.overrideAttrs (super: {
  #       postFixup = ''
  #         cp -r ${caveAudioFiles}/Google-Cave-1.0-Cave $out/share/alsa/ucm/
  #         ln -s $out/share/alsa/ucm/Google-Cave-1.0-Cave/ $out/share/alsa/ucm/sklnau8825max
  #       '';
  #     });
  #   }
  # ];
}
