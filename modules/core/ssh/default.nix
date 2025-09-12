{
  inputs,
  home-manager,
  pkgs,
  username,
  ...
}:
{
  home-manager.users.${username} = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "cave" = {
          hostname = "192.168.1.30";
        };
        "instance-20250201-1204" = {
          hostname = "79.72.68.252";
          user = "ubuntu";
          identityFile = [
            "~/.ssh/instance-20250201-1204.key"
          ];
        };
        "*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
      };
    };
  };
}
