{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.theme = pkgs.minimal-grub-theme;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelModules = [ "uinput" ];
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';

  #Hibernation pretty please?
  systemd.services.systemd-hibernate = {
    serviceConfig.ExecStart = lib.mkForce [
      ""
      "${pkgs.bash}/bin/bash -c 'echo shutdown > /sys/power/disk && echo disk > /sys/power/state'"
    ];
  };

  #Boot screen
  boot = {
    plymouth = {
      enable = true;
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
      "resume=UUID=fb0d1ebd-bdc8-435d-8dad-da61106342e2"
    ];
    loader.timeout = 5;

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
    PS1="\[\033[1;32m\][\u@\h:\w]\$\[\033[0m\]"
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

  #Login screen ReGreet config
  programs.regreet = {
    enable = true;
    theme.name = "Materia";
    font = {
      name = "Cantarell";
      size = 16;
    };
    cursorTheme.name = "graphite-light";
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
    image=/home/simon/Bilder/walls/x1pad.jpeg
    clock
    timestr=%H:%M
    datestr=%A, %d %B
    effect-blur=1x1
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

  security.sudo.extraRules = [
    {
      users = [ "simon" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start systemd-hibernate";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

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

    #Graphical utilities
    alacritty #The only good terminal emulator
    xfce.thunar #Good file browser
    localsend # Open source airdrop
    nwg-look #GTK settings editor
    lite-xl #Graphical text editor
    qimgv #Image viewer
    vlc #Video player
    audacious #Music player
    pavucontrol #Audio settings
    networkmanagerapplet #Network manager in the systray
    gparted #Partition editor
    qalculate-gtk #Calculator on roids
    handbrake #Media tool

    #Laptop utils
    auto-cpufreq #Automatic cpu frequency adjuster
    fprintd #Fingerprint authentication

    #Themes
    materia-theme
    materia-theme-transparent
    materia-kde-theme
    papirus-icon-theme
    graphite-cursors

    #GUI programs
    milkytracker
  ];

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      cantarell-fonts
    ];
  };

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

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
  services.auto-cpufreq.enable = true;
  services.playerctld.enable = true;
  services.blueman.enable = true;
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


  # system.copySystemConfiguration = true;

  system.stateVersion = "25.11"; # Did you read the comment? DO NOT EVER EDIT!!!
}
