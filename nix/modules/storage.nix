{ config, pkgs, vars, ... }:

{
  # RAID setup
  boot.initrd.mdadm.allowDisksNotFound = true;
  boot.initrd.mdadm.devices = [
    {
      name = "md0";
      level = "1";
      devices = [ vars.disk1 vars.disk2 ];
    }
  ];

  fileSystems = {
    "${vars.mountDir}" = {
      device = "/dev/md0";
      fsType = "btrfs";
    };
  };

  # RAID1 monitoring
  services.mdadm = {
    enable = true;
    monitor = true;
  };
}
