{ config, pkgs, vars, ... }:

{
  # Enable support for Linux MD RAID arrays.
  boot.swraid.enable = true;

  # Define the mdadm configuration
  boot.swraid.mdadmConf = ''
    DEVICE ${vars.disk1} ${vars.disk2}

    # Define the RAID array
    ARRAY /dev/md0 level=raid1 num-devices=2 metadata=1.2 name=myraid:0 UUID=91d4d1ed-55b0-4936-9934-34f2311a700b

    # List the devices in the array
    devices=${vars.disk1},${vars.disk2}
  '';

  # Mount device md0 to the given directory defined in 'mountDir'
  fileSystems = {
    "${vars.mountDir}" = {
      device = "/dev/md0";
      fsType = "btrfs";
    };
  };
}
