{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Stockholm";

  i18n.defaultLocale = "sv_SE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;

  users.users.simon = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;

  programs.niri.enable = true;
  programs.waybar.enable = true;
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    #Terminal utilities
    vim #Text editor
    neovim #Better vim
    wget #Download from internet
    btop #Task manager
    fastfetch #System info
    cava #Music visualizer
    rmpc #Music player for MPD
    chafa #Make ascii images
    yt-dlp #Download media
    tealdeer #TLDR manpages
    mpv #Media player in the terminal
    ncdu #See file space usage
    bluetui #Bluetooth TUI
    impala #WiFi TUI
    yazi #TUI file manager
    fzf #Find stuff
    ly #TUI login
    git #Git
    gpt-cli #chtgpt in terminal lol

    #Better CLI utils
    bat #cat
    eza #ls
    fd #find

    #Samba stuff
    cifs-utils
    samba
    gvfs

    #Different wm utils
    swww #Animated wallpaper daemon
    waypaper #Wallpaper setter

    #Graphical utilities
    alacritty #The only good terminal emulator
    fuzzel #Program launcher
    xfce.thunar #Good file browser
    localsend # Open source airdrop
    nwg-look #GTK settings editor
    lite-xl #Graphical text editor

    #Themes
    materia-theme
    materia-theme-transparent
    materia-kde-theme
    material-icons
    material-symbols
    material-cursors
    papirus-icon-theme

    #Fonts
    #nerd-fonts.iosevka

    #Funny shit
    bucklespring #make funny keyboard noise
    bucklespring-libinput #keyboard noise for libinput
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
  ];

  #Desktop portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
    ];
    config = {
      common = {
        default = "wlr";
      };
    };
  };

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  #Services
  services.gvfs.enable = true;

  # system.copySystemConfiguration = true;

  system.stateVersion = "25.11"; # Did you read the comment? DO NOT EVER EDIT!!!
}

