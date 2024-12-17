{ config, pkgs, vars, ... }:

{
  networking.firewall.interfaces.ens4.allowedTCPPorts = [
    80
    443
    8000
  ];

  virtualisation = {
    docker.enable = true;
    
    oci-containers.backend = "docker";
    oci-containers.containers = {
      # Reverse Proxy (8000)
      zoraxy = {
        image = "zoraxydocker/zoraxy:latest";
        hostname = "zoraxy";
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
        extraOptions = [
          "--network=stack"
          "--pull=newer"
        ];
      };

      # Dashboard (8080)
      glance = {
        image = "glanceapp/glance";
        hostname = "glance";
        autoStart = true;
        volumes = [
          "${vars.DIR}/glance/glance.yml:/app/glance.yml"
          "/etc/timezone:/etc/timezone:ro"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=stack"
          "--pull=newer"
        ];
      };

      # Document Management (8000)
      paperless-redis = {
        image = "redis:alpine";
        hostname = "paperless-redis";
        autoStart = true;
        volumes = [ "${vars.DIR}/paperless-ngx/redis:/data" ];
        extraOptions = [
          "--network=stack"
          "--pull=newer"
        ];
      };
      paperless = {
        image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
        hostname = "paperless";
        autoStart = true;
        dependsOn = [ "paperless-redis" ];
        volumes = [ "${vars.DIR}/paperless-ngx/data:/usr/src/paperless" ];
        environment = {
          PAPERLESS_REDIS = "redis://paperless-redis:6379";
          PAPERLESS_ADMIN_USER = vars.paperlessUsr;
          PAPERLESS_ADMIN_PASSWORD = vars.paperlessPwd;
          PAPERLESS_ADMIN_MAIL = vars.paperlessMail;
        };
        extraOptions = [
          "--network=stack"
          "--pull=newer"
        ];
      };

      # Cloud Solution (80)
      nextcloud-db = {
        image = "mariadb:latest";
        hostname = "nextcloud-db";
        autoStart = true;
        volumes = [ "${vars.DIR}/nextcloud/db:/var/lib/mysql" ];
        environment = {
          MYSQL_ROOT_PASSWORD = "nextcloud";
          MYSQL_DATABASE = "nextcloud";
          MYSQL_USER = "nextcloud";
          MYSQL_PASSWORD = "nextcloud";
        };
        extraOptions = [
          "--network=stack"
          "--pull=newer"
        ];
      };
      nextcloud-redis = {
        image = "redis:alpine";
        hostname = "nextcloud-redis";
        autoStart = true;
        volumes = [ "${vars.DIR}/nextcloud/redis:/data" ];
        extraOptions = [
          "--network=stack"
          "--pull=newer"
        ];
      };
      nextcloud = {
        image = "nextcloud:latest";
        hostname = "nextcloud";
        autoStart = true;
        dependsOn = [ "nextcloud-db" "nextcloud-redis" ];
        volumes = [
          "${vars.DIR}/nextcloud/app:/var/www/html"
          "${vars.DIR}/paperless-ngx/data:/paperless"
        ];
        environment = {
          MYSQL_HOST = "nextcloud-db"
          MYSQL_DATABASE = "nextcloud";
          MYSQL_USER = "nextcloud";
          MYSQL_PASSWORD = "nextcloud";
          REDIS_HOST = "nextcloud-redis";
          REDIS_HOST_PORT = "6379";
          NEXTCLOUD_ADMIN_USER = vars.nextcloudUsr;
          NEXTCLOUD_ADMIN_PASSWORD = vars.nextCloudPwd;
        };
        extraOptions = [
          "--network=stack"
          "--pull=newer"
        ];
      };

      # Personal Finance (5006)
      actual-budget = {
        image = "docker.io/actualbudget/actual-server:latest";
        hostname = "actual-budget";
        autoStart = true;
        volumes = [ "${vars.DIR}/actual-budget:/data" ];
        extraOptions = [
          "--network=stack"
          "--pull=newer"
        ];
      };
    };
  };

  system.activationScripts.createVolumes = {
    text = ''
      #!/bin/bash
      set -e

      ensure_directory() {
        local dir_path="$1"
        local owner="$2"
        local group="$3"

        if [ ! -d "$dir_path" ]; then
          mkdir -p "$dir_path" || echo "Error: Failed to create directory $dir_path"
          chown "$owner:$group" "$dir_path" || echo "Error: Failed to set ownership on $dir_path"
          echo "Created directory: $dir_path and set ownership to $owner:$group."
        else
          echo "Directory already exists: $dir_path. Skipping creation."
        fi
      }

      ensure_file() {
        local file_path="$1"
        local owner="$2"
        local group="$3"
        local permissions="$4"

        if [ ! -f "$file_path" ]; then
          touch "$file_path" || echo "Error: Failed to create file $file_path"
          chmod "$permissions" "$file_path" || echo "Error: Failed to set permissions on $file_path"
          chown "$owner:$group" "$file_path" || echo "Error: Failed to set ownership on $file_path"
          echo "Created file: $file_path with permissions $permissions and ownership $owner:$group."
        else
          echo "File already exists: $file_path. Skipping creation."
        fi
      }

      # Check for required variables
      if [ -z "${vars.DIR}" ] || [ -z "${vars.PUID}" ] || [ -z "${vars.PGID}" ]; then
        echo "Error: Required variables are missing. Check vars.DIR, vars.PUID, and vars.PGID."
        exit 1
      fi

      # Zoraxy volume
      ensure_directory "${vars.DIR}/zoraxy" "${vars.PUID}" "${vars.PGID}"

      # Glance volume
      ensure_directory "${vars.DIR}/glance" "${vars.PUID}" "${vars.PGID}"
      ensure_file "${vars.DIR}/glance/glance.yml" "${vars.PUID}" "${vars.PGID}" "644"

      # Paperless volumes
      ensure_directory "${vars.DIR}/paperless-ngx/redis" "${vars.PUID}" "${vars.PGID}"
      ensure_directory "${vars.DIR}/paperless-ngx/data" "${vars.PUID}" "${vars.PGID}"

      # Nextcloud volumes
      ensure_directory "${vars.DIR}/nextcloud/db" "${vars.PUID}" "${vars.PGID}"
      ensure_directory "${vars.DIR}/nextcloud/redis" "${vars.PUID}" "${vars.PGID}"
      ensure_directory "${vars.DIR}/nextcloud/app" "${vars.PUID}" "${vars.PGID}"
	  
	    # Actual volumes
      ensure_directory "${vars.DIR}/actual-budget" "${vars.PUID}" "${vars.PGID}"
    '';
  };
}