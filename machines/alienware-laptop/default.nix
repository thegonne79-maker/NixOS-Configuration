# Alienware 18 Area 51 Laptop Configuration
# RTX 5090 GPU, Intel CPU - Full LINDA feature parity
{ config, pkgs, self, lib, hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../services/ollama.nix
    ../../services/litellm.nix
    ../../modules/enable-wg.nix
    ../../lib/rclone-target.nix
    ../../environments/i3wm_darthpjb.nix
    ../../environments/steam.nix
    ../../environments/code.nix
    ../../environments/neovim.nix
    ../../environments/communications.nix
    ../../environments/emacs.nix
    ../../environments/browsers.nix
    ../../environments/mudd.nix
    ../../environments/cad_and_graphics.nix
    ../../environments/3dPrinting.nix
    ../../environments/audio_visual_editing.nix
    ../../environments/general_fonts.nix
    ../../environments/video_call_streaming.nix
    ../../environments/cloud_and_backup.nix
    ../../locale/tailscale.nix
    ../../environments/rtl-sdr.nix
    ../../modifier_imports/bluetooth.nix
    ../../modifier_imports/memtest.nix
    ../../modifier_imports/hosts.nix
    ../../modifier_imports/zfs.nix
    ../../modifier_imports/virtualisation-libvirtd.nix
    ../../modifier_imports/virtualisation-vmware.nix
    ../../environments/sshd.nix
    ../../modifier_imports/cuda.nix
    ../../modifier_imports/remote-builder.nix
    ../../users/darthpjb.nix
  ];

  environment = {
    vpn = {
      enable = true;
      postfix = 50;  # Unique IP: 10.88.127.50 for Tailscale
    };
    rclone-target = {
      enable = true;
      configFile = "${self}/secrets/rclone-config-file";
      targets = {
        obsidian-v3 = {
          filePath = " /bulk-storage/50-DB-v3/";
          remoteName = "minio:obsidian-v3";
          syncInterval = 60; # every minute
        };
      };
    };
  };

  # Laptop networking
  networking = {
    hostId = "1b7840e4";
    useDHCP = lib.mkDefault true;
    firewall = {
      allowedTCPPorts = [ 22 1108 47984 47989 47990 48010 4010 27015 4549 24070 ];
      allowedUDPPorts = [ 2108 2107 4010 27015 4175 4179 4171 47998 47999 48000 48002 ];
      allowedTCPPortRanges = [
        { from = 17780; to = 17785; }
        { from = 47984; to = 48010; }
      ];
      allowedUDPPortRanges = [
        { from = 17780; to = 17785; }
        { from = 27031; to = 27036; }
        { from = 47984; to = 48010; }
      ];
    };
  };

  # NVIDIA RTX 5090 configuration
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      nvidiaSettings = true;
      open = false;
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  # Sunshine for streaming (Moonlight compatible)
  services.sunshine = {
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = true;
  };

  # Docker support
  virtualisation.docker.enable = true;

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    # Power management
    powertop
    acpi

    # Remote access
    rustdesk

    # Gaming
    steam
    lutris

    # VM and passthrough
    self.inputs.nixpkgs_unstable.legacyPackages.x86_64-linux.looking-glass-client
    self.inputs.nixpkgs_unstable.legacyPackages.x86_64-linux.scream
    virtiofsd
    gwe
    virt-manager
  ];

  # Nix build settings for laptop
  nix = {
    settings = {
      max-jobs = lib.mkForce 8;
      cores = lib.mkDefault 0;
      download-buffer-size = 524288000;
    };
    nrBuildUsers = 8;
  };

  # Audio configuration with Discord/Vivaldi fixes
  services.pipewire = {
    extraConfig.pipewire-pulse = {
      "50-discord-block-source-volume" = {
        "pulse.rules" = [
          {
            matches = [
              { application.process.binary = "Discord"; }
              { application.process.binary = ".Discord-wrapped"; }
              { application.process.binary = "discord"; }
              { application.process.binary = "*[Dd]iscord*"; }
            ];
            actions = { quirks = [ "block-source-volume" ]; };
          }
        ];
      };
      "50-vivaldi-block-source-volume" = {
        "pulse.rules" = [
          {
            matches = [
              { application.process.binary = "*[V]ivaldi*"; }
            ];
            actions = { quirks = [ "block-source-volume" ]; };
          }
        ];
      };
    };
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # System services
  services.printing.enable = true;
  services.guix.enable = true;
  programs.adb.enable = true;
  users.users.John88.extraGroups = [ "adbusers" ];

  # Auto-start user services
  systemd.user.services = {
    obsidian = {
      description = "obsidian-autostart";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Restart = "always";
        ExecStart = ''
          ${pkgs.obsidian}/bin/obsidian
        '';
        PassEnvironment = "DISPLAY XAUTHORITY";
      };
    };
    dino = {
      description = "dino-autostart";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Restart = "always";
        ExecStart = ''
          ${pkgs.dino}/bin/dino
        '';
        PassEnvironment = "DISPLAY XAUTHORITY";
      };
    };
    discord = {
      description = "discord-autostart";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Restart = "always";
        ExecStart = ''
          ${pkgs.discord}/bin/discord
        '';
        PassEnvironment = "DISPLAY XAUTHORITY";
      };
    };
    scream-ivshmem = {
      enable = true;
      description = "Scream br0";
      serviceConfig = {
        ExecStart = "${pkgs.scream}/bin/scream -u -i wlan0 -p 4010";
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "pipewire.service" ];
    };
  };

  # Tmpfiles for Looking Glass
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 John88 qemu-libvirtd -"
    "d /rendercache 0755 John88 users"
  ];

  # Timezone
  time.timeZone = "Etc/UTC";

  # Boot configuration
  boot = {
    tmp.useTmpfs = false;
    supportedFilesystems = [ "zfs" "ntfs" ];
    zfs.extraPools = [ "speed-storage" "bulk-storage" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    ];
  };
}
