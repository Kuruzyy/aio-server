{ config, pkgs, ... }:

{
  # Configuration for automatic NixOS upgrades
  system.autoUpgrade = {
    enable = true;
    schedule = "daily";
  };

  # Enable SSD optimization
  services.fstrim.enable = true;

  # Add system packages
  environment.systemPackages ++= with pkgs; [
    mc
    btop
    ctop
  ];
}