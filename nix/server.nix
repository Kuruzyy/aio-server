{ config, pkgs, ... }:

let
  vars = {
		# Containers environment configurations
    siyuanPwd = "siyuan";
    TZ = "Asia/Kuala_Lumpur";
    PGID = "1000";
    PUID = "1000";
    DIR = "/mnt/raid/config";
    domainName = "home.local";
	
    # RAID1 disk UUIDs
    disk1 = /dev/disk/by-id/ata-disk1
    disk2 = /dev/disk/by-id/ata-disk2
  };
in
{
  # Configuration for automatic NixOS upgrades
  system.autoUpgrade = {
    enable = true;
    schedule = "daily";
  };

  # Enabled to optimize SSD
  services.fstrim = {
    enable = true;
  };

  # System packages (mdadm, mc, btop)
  environment.systemPackages ++= with pkgs; [
    mdadm
    mc
    btop
  ];

  # RAID setup
  boot.initrd.mdadm.allowDisksNotFound = true;
  boot.initrd.mdadm.devices = [
    {
      name = "md0";
      level = "1";
      devices = [ "${vars.disk1}" "${vars.disk2}" ];
    }
  ];

  fileSystems = {
    "/mnt/raid" = {
      device = "/dev/md0";
      fsType = "btrfs";
    };
  };

  # RAID1 monitoring
  services.mdadm = {
    enable = true;
    monitor = true;
  };

  # Enable container support & configure Podman
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Define containers using Podman backend
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      # Reverse Proxy
      zoraxy = {
        image = "zoraxydocker/zoraxy:latest";
        autoStart = true;
        ports = [ "80:80" "443:443" "8000:8000" ];
        volumes = [
          "${vars.DIR}/zoraxy:/opt/zoraxy/config/"
          "/etc/localtime:/etc/localtime"
        ];
        environment = {
          FASTGEOIP = "true";
          ZEROTIER = "true";
        };
        networks = [ "stack" ];
      };

      # Dashboard
      glance = {
        image = "glanceapp/glance";
        autoStart = true;
        volumes = [
          "${vars.DIR}/glance/glance.yml:/app/glance.yml"
          "/etc/timezone:/etc/timezone:ro"
          "/etc/localtime:/etc/localtime:ro"
        ];
        networks = [ "stack" ];
      };

      # Password Manager
      vaultwarden = {
        image = "vaultwarden/server:latest";
        autoStart = true;
        volumes = [ "${vars.DIR}/vaultwarden:/data" ];
        environment = {
          DOMAIN = "passwords.${vars.domainName}";
        };
        networks = [ "stack" ];
      };
      
      # Document Management
      paperless-redis = {
        image = "redis:alpine";
        autoStart = true;
        volumes = [ "${vars.DIR}/paperless-ngx/redis:/data" ];
        networks = [ "stack" ];
      };

      paperless = {
        image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
        autoStart = true;
        dependsOn = [ "paperless-redis" ];
        volumes = [ "${vars.DIR}/paperless-ngx/data:/usr/src/paperless" ];
        environment = {
          PAPERLESS_REDIS = "redis://paperless-redis:6379";
        };
        networks = [ "stack" ];
      };

      # Knowledge Management
      siyuan = {
        image = "b3log/siyuan";
        autoStart = true;
        command = [
          "--workspace=/siyuan/workspace/"
          "--accessAuthCode=${vars.siyuanPwd}"
        ];
        volumes = [ "${vars.DIR}/siyuan:/siyuan/workspace" ];
        environment = {
          TZ = "${vars.TZ}";
          PUID = "${vars.PUID}";
          PGID = "${vars.PGID}";
        };
        networks = [ "stack" ];
      };

      # Cloud Solution
      nextcloud-db = {
        image = "mariadb:latest";
        autoStart = true;
        volumes = [ "${vars.DIR}/nextcloud/db:/var/lib/mysql" ];
        environment = {
          MYSQL_ROOT_PASSWORD = "nextcloud";
          MYSQL_DATABASE = "nextcloud";
          MYSQL_USER = "nextcloud";
          MYSQL_PASSWORD = "nextcloud";
        };
        networks = [ "stack" ];
      };

      nextcloud-redis = {
        image = "redis:alpine";
        autoStart = true;
        volumes = [ "${vars.DIR}/nextcloud/redis:/data" ];
        networks = [ "stack" ];
      };

      nextcloud = {
        image = "nextcloud:latest";
        autoStart = true;
        dependsOn = [ "nextcloud-db" "nextcloud-redis" ];
        volumes = [ "${vars.DIR}/nextcloud/app:/var/www/html" ];
        environment = {
          NEXTCLOUD_DB_TYPE = "mysql";
          NEXTCLOUD_DB_HOST = "nextcloud-db";
          NEXTCLOUD_DB_NAME = "nextcloud";
          NEXTCLOUD_DB_USER = "nextcloud";
          NEXTCLOUD_DB_PASSWORD = "nextcloud";
          REDIS_HOST = "nextcloud-redis";
          REDIS_HOST_PORT = "6379";
        };
        networks = [ "stack" ];
      };
    };

    networks = { stack = {}; };
  };

  system.activationScripts.createVolumes = {
    text = ''
      # Zoraxy volume
      mkdir -p ${vars.DIR}/zoraxy
      chown ${vars.PUID}:${vars.PGID} ${vars.DIR}/zoraxy

      # Glance volume
      mkdir -p ${vars.DIR}/glance
      touch ${vars.DIR}/glance/glance.yml
      chmod 644 ${vars.DIR}/glance/glance.yml
      chown ${vars.PUID}:${vars.PGID} ${vars.DIR}/glance/glance.yml

      # Vaultwarden volume
      mkdir -p ${vars.DIR}/vaultwarden
      chown ${vars.PUID}:${vars.PGID} ${vars.DIR}/vaultwarden

      # Paperless volume
      mkdir -p ${vars.DIR}/paperless-ngx/redis
      mkdir -p ${vars.DIR}/paperless-ngx/data
      chown ${vars.PUID}:${vars.PGID} ${vars.DIR}/paperless-ngx/redis ${vars.DIR}/paperless-ngx/data

      # Siyuan volume
      mkdir -p ${vars.DIR}/siyuan
      chown ${vars.PUID}:${vars.PGID} ${vars.DIR}/siyuan

      # Nextcloud volume
      mkdir -p ${vars.DIR}/nextcloud/db
      mkdir -p ${vars.DIR}/nextcloud/redis
      mkdir -p ${vars.DIR}/nextcloud/app
      chown ${vars.PUID}:${vars.PGID} ${vars.DIR}/nextcloud/db ${vars.DIR}/nextcloud/redis ${vars.DIR}/nextcloud/app
    '';
  };
}
