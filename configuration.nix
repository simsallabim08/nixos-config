{ config, lib, pkgs, ... }:

#Theme packageing
let
  nashville96 = pkgs.stdenv.mkDerivation {
    name = "nashville96";
    src = pkgs.fetchFromGitHub {
      owner = "donfaustinocortizone";
      repo = "Nashville96";
      rev = "master";
      sha256 = "1x8rbgxs9x5af8hv6xk6aha4sz6yciis35jzfrpqqdddvf6a032v";
    };
    installPhase = ''
      mkdir -p $out/share/themes
      cp -r Themes/* $out/share/themes
    '';
    dontBuild = true;
  };
  
  modernxp-cursors = pkgs.stdenv.mkDerivation {
    name = "modernxp-cursors";
    src = pkgs.fetchurl {
      url = "https://github.com/na0miluv/modernXP-cursor-theme/releases/download/final/ModernXP.tar.gz";
      sha256 = "sha256-W0OdG4OPGbZn1WX5vHxeQ1EYp+9gyyl19Glc4ha2vgM";
    };
    unpackPhase = ''
      tar -xzf $src
    '';
    installPhase = ''
      mkdir -p $out/share/icons
      cp -r ModernXP $out/share/icons/
    '';
    dontBuild = true;
  };
in

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
    #theme = pkgs.minimal-grub-theme;
    timeoutStyle = "hidden";
    memtest86.enable = true;
    splashImage = null;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelModules = [ "uinput" ];
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';

  #Boot screen
  boot = {
    plymouth = {
      enable = false; #True: grapical. False: text.
      theme = "rings";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    # Enable "Silent-ish boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
  };

  #Network and wireless stuff
  networking.hostName = "T410";

  networking = {
    networkmanager = {
      enable = true;
      dns = "none";
      wifi = {
	powersave = true;
      };
    };
    nameservers = [
      "9.9.9.9"
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
  
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  #Time and language stuff
  time.timeZone = "Europe/Stockholm";

  i18n.defaultLocale = "sv_SE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };

  services.xserver.xkb.layout = "se";

  #PS1 prompt fixed without shitty newline
  programs.bash.promptInit = ''
    PS1="\[\033[1;32m\][\u@\h:\w]\$\[\033[0m\] "
  '';

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  services.libinput.enable = true;

  users.users.simon = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "input" ];
    packages = with pkgs; [
    ];
  };

  users.users.jeanette = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "input" ];
  };

  #Login screen ReGreet config
  programs.regreet = {
    enable = true;
    theme.name = "Nashville96-Kanagawa";
    font = {
      name = "Fixedsys Excelsior 3.01";
      size = 16;
    };
    cursorTheme.name = "ModernXP";
  };
  programs.regreet.settings = {
    background = {
      path = "/usr/share/wallpapers/x1pad.jpeg";
      fit = "Cover";
    };
    GTK = {
      application_prefer_dark_theme = true;
    };
  };

  #Greet Daemon (greetd)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -s -d -m extend -- ${pkgs.regreet}/bin/regreet";
        user = "greeter";
      };
    };
  };

  #Swaylock config
  environment.etc."swaylock/config".text = ''
    font=Fixedsys Excelsior 3.01
    image=/home/simon/Bilder/walls/x1pad.jpeg
    clock
    timestr=%H:%M
    datestr=%A, %d %B
    effect-blur=4x6
    effect-vignette=0.5:0.8
    indicator
    indicator-radius=100
    indicator-thickness=7
    color=1e1e2edd
    inside-color=1e1e2e88
    ring-color=cdd6f4ff
    text-color=cdd6f4ff
    line-color=00000000
    show-failed-attempts
    fade-in=0.2
  '';

  #PAM fingerprint stuff
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.greetd.fprintAuth = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.swaylock-effects = {};

  #Seciruty
  security.polkit.enable = true;

  #Programs
  programs.firefox.enable = true;
  programs.niri.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

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
    git #Git
    inxi #System info
    pciutils #Lspci command
    usbutils #lsusb
    wiremix #Audio output tui
    ncdu #See disk space usage
    dust #Same as above
    aria2 #Fast downloader
    asciinema #Terminal recorder
    ffmpeg_7-full #Multimedia stuff
    cht-sh #Cheat-sheet
    ddrescue #Data recovery
    nmap #Scan network
    thc-hydra #Crack passwords
    gnutar #Tar but gnu??
    mitmproxy #MiM attacker
    python313Packages.howdoi #Howto in terminal
    rsync #File transfer
    tealdeer #TLDR for MAN
    streamlink #Terminal streaming
    ddgr #Terminal DDG
    sox #Audio sample rate converter
    taskwarrior3 #ToDo list
    dogdns #DNS client
    fail2ban #Security ip blocker
    nethogs #BTOP for network usage
    f3 #Counterfeit storage finder
    gifsicle #GIF manipulation
    abcde #Disk yoinker
    chafa #Turn images into ASCII art
    gophertube #TUI youtube???
    tmux #Teminal multiplexer
    caligula #Safer dd
    pastel #Colors
    astroterm #Celestial viewer
    figlet #Large text
    espeak-classic #SAM
    screen #serial connector


    #Better CLI utils
    bat #cat
    eza #ls
    fd #find

    #Samba stuff
    cifs-utils
    samba
    gvfs

    #Development tools
    gcc #C compiler
    gnumake #Build system

    #Different wm tools
    swww #Animated wallpaper daemon
    waypaper #Wallpaper setter
    waybar #Simple bar for wayland
    wofi #Launcher
    pywal16 #Colorscheme generator
    wlogout #Logout screen
    swaynotificationcenter #Notifications
    swaylock-effects #Sway lock screen but better
    cage #login compositor
    xdg-desktop-portal-gtk #xdg portal for niri
    wob #On screen display
    quickshell #QtQuick shell making (hard to do)
    wdisplays #Screen configurator

    #Graphical programs
    alacritty #The only good terminal emulator
    xfce.thunar #Good file browser
    xfce.tumbler #Thumbnails for thunar
    pkgs.xfce.thunar-archive-plugin #Archiving thunar
    file-roller #Archiver
    localsend # Open source airdrop
    nwg-look #GTK settings editor
    kdePackages.qt6ct #Qt6 settings editor
    libsForQt5.qt5ct #Qt5 settings editor
    lite-xl #Graphical text editor
    qimgv #Image viewer
    vlc #Video player
    audacious #Music player
    pavucontrol #Audio settings
    networkmanagerapplet #Network manager in the systray
    gparted #Partition editor
    qalculate-gtk #Calculator on roids
    handbrake #Media tool
    obs-studio #Recording tool
    vesktop #Discord client
    arrpc #Rich prescense for vesktop
    cheese #Webcam software
    font-manager #Its in the name
    kdePackages.okular #pdf viewer
    milkytracker #Music program
    kdePackages.ark #Unarchiver and archiver
    kdePackages.dolphin #File manager
    wireshark #Network tool
    virtualbox #VM manager

    #Laptop utils
    auto-cpufreq #Automatic cpu frequency adjuster
    fprintd #Fingerprint authentication

    #Themes
    materia-theme
    materia-theme-transparent
    materia-kde-theme
    papirus-icon-theme
    graphite-cursors
    hackneyed
    nashville96
    chicago95
    modernxp-cursors

    #Fun
    bucklespring-libinput #Buckling spring kb sounds
    asciicam #Webcam in ASCII
    cmatrix


    ## TEMP KDE ##
    kdePackages.kcalc # Calculator
    kdePackages.kcharselect # Character map
    kdePackages.kclock # Clock app
    kdePackages.kcolorchooser # Color picker
    kdePackages.kolourpaint # Simple paint program
    kdePackages.ksystemlog # System log viewer
    kdiff3 # File/directory comparison tool
  
    # Hardware/System Utilities (Optional)
    kdePackages.isoimagewriter # Write hybrid ISOs to USB
    kdePackages.partitionmanager # Disk and partition management
    hardinfo2 # System benchmarks and hardware info
    wayland-utils # Wayland diagnostic tools
    wl-clipboard # Wayland copy/paste support
    vlc # Media player

  ];

  #Fonts
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      nerd-fonts.bigblue-terminal
      cantarell-fonts
      uni-vga
      fixedsys-excelsior
    ];
  };


  #TEMP KDE INSTALL
  services.desktopManager.plasma6.enable = true;

  

  #networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = true;

  #Services
  services.gvfs.enable = true;
  services.mpd = {
    enable = true;
    user = "simon";
    musicDirectory = "/home/simon/Musik";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire"
      }
    '';
  };
  #services.auto-cpufreq.enable = true;
  services.playerctld.enable = true;
  services.blueman.enable = true;
  services.sshd.enable = false;
  services.fprintd = {
    enable = true;
  };

  systemd.user.services.wob = {
    description = "Wayland Overlay Bar";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'rm -f $XDG_RUNTIME_DIR/wob.sock && mkfifo $XDG_RUNTIME_DIR/wob.sock'";
      ExecStart = "${pkgs.bash}/bin/bash -c 'tail -f $XDG_RUNTIME_DIR/wob.sock | ${pkgs.wob}/bin/wob'";
      Restart = "on-failure";
    };
  };
  systemd.user.services.arrpc = {
    description = "arRPC Discord Rich Presence Bridge";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.arrpc}/bin/arrpc";
      Restart = "on-failure";
    };
  };

  powerManagement.powertop.enable = true;

  ##ENV Vars
  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };


  # system.copySystemConfiguration = true;

  system.stateVersion = "25.11"; # Did you read the comment? DO NOT EVER EDIT!!!
}
