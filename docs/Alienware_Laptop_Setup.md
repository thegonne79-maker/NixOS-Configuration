# Alienware Laptop Setup Guide

## Configuration Created
- **Machine**: `alienware-laptop`
- **Location**: `/home/tank/PJB-NixOS-Configuration/machines/alienware-laptop/`
- **Tailscale IP**: `100.74.110.25`
- **WireGuard IP**: `10.88.127.50`

## Next Steps

### 1. Generate Hardware Configuration on Laptop
```bash
# On the laptop, run:
sudo nixos-generate-config --show-hardware-config > /tmp/hardware-configuration.nix
```
Then copy the output and replace the placeholder in:
`/home/tank/PJB-NixOS-Configuration/machines/alienware-laptop/hardware-configuration.nix`

### 2. Generate WireGuard Keys
```bash
# On the laptop:
wg genkey | tee ~/wg_private | wg pubkey > ~/wg_public

# Copy the private key to secrets:
scp ~/wg_private tank@100.113.169.51:/home/tank/PJB-NixOS-Configuration/secrets/private_keys/wireguard/wg_alienware-laptop

# Copy public key:
scp ~/wg_public tank@100.113.169.51:/home/tank/PJB-NixOS-Configuration/secrets/public_keys/wireguard/wg_alienware-laptop_pub
```

### 3. Encrypt the Private Key with secrix
```bash
cd /home/tank/PJB-NixOS-Configuration
nix run .#secrix create ./secrets/private_keys/wireguard/wg_alienware-laptop -- -u John88 < ./secrets/private_keys/wireguard/wg_alienware-laptop
```

### 4. SSH Host Key
```bash
# On the laptop:
sudo cat /etc/ssh/ssh_host_ed25519.pub > ~/host_key.pub

# Copy to secrets:
scp ~/host_key.pub tank@100.113.169.51:/home/tank/PJB-NixOS-Configuration/secrets/public_keys/host_keys/alienware-laptop.pub
```

### 5. Test Configuration
```bash
cd /home/tank/PJB-NixOS-Configuration
nix fmt
nix flake check
nixos-rebuild build --flake .#alienware-laptop
```

### 6. Deploy to Laptop
```bash
# Test deployment first:
nix run .#alienware-laptop

# If successful, make permanent:
nix run .#alienware-laptop -- switch
```

## Hardware-Specific Notes
- **GPU**: NVIDIA RTX 5090 - uses proprietary drivers with power management
- **CPU**: Intel (assumed Alienware 18 Area 51) - microcode updates enabled
- **Power**: TLP and thermald configured for laptop power management
- **Network**: Tailscale VPN configured, WireGuard for internal network
- **Streaming**: Sunshine enabled for Moonlight game streaming

## Files Created
```
machines/alienware-laptop/
├── default.nix           # Main configuration
└── hardware-configuration.nix  # Hardware config (needs update)
```

## Synced Files (Already on Laptop)
- `/home/tank/AGENTS.md`
- `/home/tank/prime_directives.md`
- `/home/tank/notes/OPENCODE_ARCHIVE_analysis.md`
- `/home/tank/OPENCODE_ARCHIVE.tar.zstd`
