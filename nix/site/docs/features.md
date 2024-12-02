# Features and Functionality

1. Configure the system for automated updates, upgrades, and SSD optimization using `fstrim`.
2. Install required dependencies and utilities, including `mc`, `btop`, and `mdadm`.
3. Create a RAID 1 pool with the NVMe drives (via `mdadm`).
4. Enable Podman for containerization, with additional configurations.
5. Deploy the following containers (Zoraxy, Glance, Vaultwarden, Paperless-NGX, SiYuan, NextCloud, Actual-Budget)
6. Include a boot-time script to create missing files and directories for the containers.
