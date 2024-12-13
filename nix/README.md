# A Cloud-solution replacement in NixOS

## Harware used
- Lenovo Thinkcentre 
- PCIe Riser
- PCIe to M.2 Adapter

## Lenovo Thinkcentre Specifications
- Intel i5-8400T
- 2x16GB DDR4 RAM
- 256GB M.2 NVMe Boot Drive
- 2x4TB NVMe RAID1 Array

## Requirements
- NixOS machine
- Local DNS / Domain set up
- flake.nix configured (look into the 'Centralized variables' section)

## What it does
1) Configure the system for automated updates & upgrades + fstrim for SSD optimisation.
2) Installs required dependencies / comfort use (includes 'mc', 'btop' and 'mdadm').
3) Creates a RAID 1 Pool with the NVMe drives (in the PCIe to M.2 Adapter) with 'mdadm'.
4) Enabled Podman support for containerisation with some configurations.
5) Deploy containers (Zoraxy, Glance, Vaultwarden, Paperless-NGX, Siyuan, NextCloud and Actual-Budget).
6) Includes a script that run on boot to create missing files and directories for the containers.

## Services included
- Zoraxy (Reverse Proxy)
- Glance (Dashboard)
- Vaultwarden (Password Management)
- Paperless-NGX (Document Management)
- SiYuan (Note-taking platform)
- NextCloud (All-in-one Cloud solution)
- Actual-Budget (Personal Finance)

## Post-Install
- Visit 'http://serverIP:8000/' to visit Zoraxy, the main reverse proxy.
- Configure reverse proxy, because it is within the same network with other containers, foward 'containerName:containerPort' will suffice.
- Repeat for all containers (Zoraxy, Glance, Vaultwarden, Paperless-NGX, Siyuan, NextCloud and Actual-Budget).

## Notes:
- Will NOT seggregate containers.nix into multiple individual containers (zoraxy.nix, vaultwarden.nix, ...).
- This is a complete Cloud-solution replacement... this repository will only contain the important services.
