# Alienware 18 Area 51 Laptop Configuration
# RTX 5090 GPU, Intel CPU - Lightweight for 64GB RAM
{ config, pkgs, self, lib, hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/enable-wg.nix
    ../../environments/i3wm_darthpjb.nix
    ../../environments/steam.nix
    ../../environments/code.nix
    ../../environments/neovim.nix
    ../../environments/communications.nix
    ../../environments/browsers.nix
    ../../environments/general_fonts.nix
    ../../locale/tailscale.nix
    ../../modifier_imports/bluetooth.nix
    ../../modifier_imports/hosts.nix
    ../../modifier_imports/zfs.nix
    ../../environments/sshd.nix
    ../../modifier_imports/cuda.nix
    ../../users/darthpjb.nix
  ];

  environment = {
    vpn = {
      enable = true;
      postfix = 50;
    };
  };

  # Laptop networking
  networking = {
    hostId = "1b7840e4";
    useDHCP = lib.mkDefault true;
    firewall = {
      allowedTCPPorts = [ 22 1108 ];
      allowedUDPPorts = [ 2108 ];
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

  # Sunshine for streaming
  services.sunshine = {
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = true;
  };

  # Laptop packages - minimal
  environment.systemPackages = with pkgs; [
    powertop
    acpi
    vulkan-tools
  ];

  # Nix build settings - very conservative
  nix = {
    settings = {
      max-jobs = lib.mkForce 2;
      cores = lib.mkDefault 0;
    };
    nrBuildUsers = 2;
  };

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Timezone
  time.timeZone = "Etc/UTC";

  # Boot configuration
  boot = {
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
