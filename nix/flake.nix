{
  description = "Cloud-solution replacement";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";

    # Centralized variables
    sharedVariables = {
      vars = {
        # Storage variables for RAID1 Pool
        disk1 = "/dev/disk/by-id/ata-disk1";
        disk2 = "/dev/disk/by-id/ata-disk2";
		    mountDir = "/mnt/raid"

        # Containers environment configurations
        siyuanPwd = "siyuan";
        TZ = "Asia/Kuala_Lumpur";
        PGID = "1000";
        PUID = "1000";
        DIR = "/mnt/raid/config";
        domainName = "home.local";
      };
    };

  in {
    nixosConfigurations = {
      myServer = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hardware-configuration.nix
          ./modules/storage.nix
          ./modules/general-settings.nix
          ./services/containers.nix
          ({ config, pkgs, ... }: sharedVariables)
        ];
      };
    };
  };
}
