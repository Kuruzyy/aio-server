{ config, pkgs, ... }: {
  # Misc.
  programs.dconf.enable = true;
  services.fstrim.enable = true;
  system.autoUpgrade = {
    enable = true;
    schedule = "daily";
  };

  # Install packages
  environment.systemPackages = with pkgs; [
    flatpak
    btop
    gnome.gnome-software
  ];

  # GNOME Debloat
  services.gnome.core-utilities.enable = false;
  environment.gnome.excludePackages = with pkgs.gnome; [
    baobab
    epiphany
    atomix
    gedit
    iagno
    hitori
    simple-scan
    totem
    tali
    yelp
    evince
    file-roller
    geary
    seahorse
    gnome-photos
    gnome-tour
    gnome-text-editor
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    gnome-screenshot
    gnome-system-monitor
    gnome-weather
  ];

  # Virtualisation services
  virtualisation = {
    waydroid.enable = true;
  };
}