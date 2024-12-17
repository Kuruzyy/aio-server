{ config, pkgs, ... }:

{
    # Misc.
    services.fstrim.enable = true;
    environment.systemPackages ++= with pkgs; [
        mc
        btop
    ];

    virtualisation = {
        podman = {
            enable = true;
            socketActivate = true;
            dockerCompat = true;
            defaultNetwork.settings.dns_enabled = true;
        }

        oci-containers = {
            backend = "podman";
            containers = {
                dockge = {
                    image = "louislam/dockge:1";
                    hostname = "dockge";
                    autoStart = "true";
                    ports = [ "5001:5001" ];
                    volumes = [
                        "/var/run/podman/podman.sock:/var/run/docker.sock"
                        "/opt/dockge:/app/data"
                        "/opt/stacks:/opt/stacks"
                    ];
                    environment = {
                        DOCKGE_STACKS_DIR = "/opt/stacks"
                    };
                };
            };
        };
    };
}
