# Mullvad + OpenVPN Setup Guide

⚠️ **Note**: Mullvad is phasing out OpenVPN support in favor of WireGuard. We strongly recommend using [Mullvad + WireGuard](mullvad-wireguard.md) instead for better performance and future compatibility.

## Why Use WireGuard Instead?

- **Faster**: Significantly better speeds
- **More Secure**: Modern cryptography
- **Battery Efficient**: Lower power consumption
- **Future-proof**: Mullvad's recommended protocol
- **Simpler**: Easier configuration

**This guide is provided for compatibility purposes only.**

## Prerequisites

- Active Mullvad account
- Account number (format: XXXX XXXX XXXX XXXX)

## Configuration

### Step 1: Configure .env

```bash
VPN_PROVIDER=mullvad
VPN_TYPE=openvpn
OPENVPN_USER=your_mullvad_account_number
OPENVPN_PASSWORD=m  # Always just 'm' for Mullvad
SERVER_COUNTRIES=SE  # Optional: server location
```

### Step 2: Start the Stack

```bash
docker compose up -d
```

### Step 3: Verify

```bash
./scripts/test-vpn.sh
```

## Server Selection

Same as WireGuard:

```bash
SERVER_COUNTRIES=SE  # Sweden
SERVER_COUNTRIES=US,CA  # USA and Canada
SERVER_CITIES=Stockholm  # Specific city
```

## Troubleshooting

If connection fails:

1. Verify account number is correct
2. Password should always be `m`
3. Try different country: `SERVER_COUNTRIES=DE`
4. Check logs: `docker compose logs gluetun`

## Migration to WireGuard

**Recommended:** Switch to WireGuard for better performance:

1. Go to mullvad.net/account
2. Generate WireGuard configuration
3. Follow [Mullvad + WireGuard guide](mullvad-wireguard.md)
4. Update .env:
   ```bash
   VPN_TYPE=wireguard
   WIREGUARD_PRIVATE_KEY=your_key
   WIREGUARD_ADDRESSES=your_addresses
   ```
5. Restart: `docker compose restart`

## Additional Resources

- [Mullvad WireGuard Guide](mullvad-wireguard.md) (recommended)
- [Mullvad Website](https://mullvad.net/)
