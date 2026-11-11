{ username, ... }:
{
  home-manager.users.${username} =
    { pkgs, ... }:
    let
      addonsDir = ".local/share/Steam/steamapps/compatdata/3292023421/pfx/drive_c/Program Files (x86)/World of Warcraft/_forever_/Interface/AddOns";

      # curseforge blocks scripted downloads, so the zip has to be added to the store by hand:
      #   nix-store --add-fixed sha256 ~/Downloads/DungeonJournal-2.0.2.zip
      foreverDungeonJournal = pkgs.stdenvNoCC.mkDerivation {
        pname = "wow-forever-dungeon-journal";
        version = "2.0.2";
        src = pkgs.requireFile {
          name = "DungeonJournal-2.0.2.zip";
          url = "https://www.curseforge.com/wow/addons/dungeonjournal";
          hash = "sha256-9pTq2RKgeanp2tCJnzfydPlkb49rJrGoX8+Tjwueagk=";
        };
        nativeBuildInputs = [ pkgs.unzip ];
        sourceRoot = ".";
        installPhase = ''
          cp -r ForeverDungeonJournal $out
        '';
      };
    in
    {
      home.packages = [ pkgs.wowup-cf ];

      home.file."${addonsDir}/ForeverDungeonJournal".source = foreverDungeonJournal;
    };
}
