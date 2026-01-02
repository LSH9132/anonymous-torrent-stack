# Mullvad + WireGuard Setup Guide

Mullvad is one of the best VPN providers for privacy and strongly recommended for this stack. WireGuard is their recommended protocol.

## Why Mullvad?

- **Privacy-focused**: No logging policy, anonymous account creation
- **WireGuard native**: Built from the ground up with WireGuard support
- **No personal information**: Pay with cryptocurrency or cash
- **Transparent**: Open-source clients, regular security audits
- **Fast**: Excellent server speeds with WireGuard

## Prerequisites

- Active Mullvad account (https://mullvad.net/)
- Account number (format: XXXX XXXX XXXX XXXX)

## Step 1: Generate WireGuard Key

1. **Log in to Mullvad:**
   - Go to https://mullvad.net/account/
   - Enter your account number

2. **Generate WireGuard configuration:**
   - Scroll to "WireGuard configuration"
   - Click "Generate key" if you don't have one
   - You'll see your configuration details

3. **Copy the details** - you'll need these:
   - Private key
   - Addresses (both IPv4 and IPv6)

## Step 2: Configure .env File

Edit your `.env` file and set the following:

```bash
# VPN Provider
VPN_PROVIDER=mullvad
VPN_TYPE=wireguard

# WireGuard Configuration
WIREGUARD_PRIVATE_KEY=your_private_key_here
WIREGUARD_ADDRESSES=your_addresses_here

# Server Selection (optional)
SERVER_COUNTRIES=SE  # Sweden, or any country code you prefer
# Available: SE, US, GB, DE, NL, CA, AU, etc.

# Optional: Specific cities
# SERVER_CITIES=Stockholm,Gothenburg
```

### Example Configuration

```bash
VPN_PROVIDER=mullvad
VPN_TYPE=wireguard
WIREGUARD_PRIVATE_KEY=aBcDeFgHiJkLmNoPqRsTuVwXyZ0123456789+/ABCDEFGH=
WIREGUARD_ADDRESSES=10.68.45.123/32,fc00:bbbb:bbbb:bb01::4:2d7a/128
SERVER_COUNTRIES=SE,NO,FI  # Nordics
```

## Step 3: Start the Stack

```bash
docker compose up -d
```

## Step 4: Verify Connection

```bash
./scripts/test-vpn.sh
```

Expected output:
```
[✓] VPN IP Address: 185.65.134.66
[✓] Location: Stockholm, Sweden
[✓] VPN is working! Your IP is hidden.
```

## Server Selection

### By Country

Use [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country codes:

```bash
SERVER_COUNTRIES=SE  # Sweden only
SERVER_COUNTRIES=SE,NO,DK  # Nordic countries
SERVER_COUNTRIES=US  # United States
```

**Popular Mullvad Countries:**
- SE - Sweden
- NO - Norway
- DK - Denmark
- FI - Finland
- US - United States
- GB - United Kingdom
- DE - Germany
- NL - Netherlands
- CA - Canada
- AU - Australia
- JP - Japan

### By City

```bash
SERVER_CITIES=Stockholm
SERVER_CITIES=Stockholm,Gothenburg
```

### Automatic Selection

Leave empty for automatic selection of the best server:

```bash
SERVER_COUNTRIES=
SERVER_CITIES=
```

Gluetun will choose based on latency and load.

## Mullvad-Specific Features

### IPv6 Support

Mullvad supports IPv6. Your `WIREGUARD_ADDRESSES` includes both IPv4 and IPv6:

```bash
WIREGUARD_ADDRESSES=10.68.45.123/32,fc00:bbbb:bbbb:bb01::4:2d7a/128
                    ^^^^^^^^^^^^     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                    IPv4             IPv6
```

### Multiple Keys

You can generate multiple WireGuard keys on Mullvad (up to 5). This is useful for:
- Multiple devices
- Different locations
- Backup keys

Each key works independently.

### Port Selection

Mullvad WireGuard supports multiple ports for restrictive networks:

Default: `51820` (automatically used)

Alternative ports: `51820, 53, 80, 443, 1080, 1194, 1195, 1196, 1197, 1300, 1301, 1302`

To use an alternative port, you'd need to modify the WireGuard peer endpoint (advanced users only).

## Troubleshooting

### Connection Fails

1. **Verify your private key is correct:**
   ```bash
   # Check .env file
   grep WIREGUARD_PRIVATE_KEY .env
   ```

2. **Verify your addresses are correct:**
   ```bash
   grep WIREGUARD_ADDRESSES .env
   ```

3. **Check Gluetun logs:**
   ```bash
   docker compose logs gluetun | grep -i error
   ```

4. **Try a different country:**
   ```bash
   # In .env, change to a nearby country
   SERVER_COUNTRIES=DE  # Germany
   ```

### Slow Speeds

1. **Try a different server location:**
   - Choose geographically closer servers
   - Try: `SERVER_COUNTRIES=` (leave empty for auto-selection)

2. **Check server load:**
   - Mullvad displays server load on their website
   - Avoid servers with >90% load

3. **Verify you're using WireGuard:**
   ```bash
   grep VPN_TYPE .env
   # Should show: VPN_TYPE=wireguard
   ```

### Invalid Key Error

If you see "invalid key" errors:

1. **Regenerate your key on Mullvad:**
   - Go to mullvad.net/account
   - Delete old key
   - Generate new key
   - Update `.env` with new credentials

2. **Check for extra spaces:**
   ```bash
   # No spaces around the = sign
   WIREGUARD_PRIVATE_KEY=your_key_here  # Correct
   WIREGUARD_PRIVATE_KEY = your_key_here  # Wrong!
   ```

### Can't Access Certain Countries

Some countries may have connectivity issues. If a specific country doesn't work:

1. Try automatic selection: `SERVER_COUNTRIES=`
2. Use a different nearby country
3. Check Mullvad's server status page

## Security Recommendations

### Rotate Keys Regularly

Generate a new WireGuard key every few months:
1. Generate new key on Mullvad
2. Update `.env` with new credentials
3. Restart: `docker compose restart gluetun`

### Use Multiple Servers

Rotate between different countries for better anonymity:

```bash
# Week 1
SERVER_COUNTRIES=SE

# Week 2
SERVER_COUNTRIES=NO

# Week 3
SERVER_COUNTRIES=NL
```

### Verify DNS

Always verify you're not leaking DNS:

```bash
./scripts/test-vpn.sh
# Should show DNS over TLS enabled
```

## Performance Tips

### Choose Nearby Servers

For best performance, select geographically close servers:

**North America:**
```bash
SERVER_COUNTRIES=US,CA
```

**Europe:**
```bash
SERVER_COUNTRIES=SE,NO,DK,FI,DE,NL
```

**Asia:**
```bash
SERVER_COUNTRIES=JP,SG,HK
```

### Enable Caching

DNS caching is enabled by default for better performance:

```bash
DOT_CACHING=on  # Already in .env
```

## Additional Resources

- [Mullvad Website](https://mullvad.net/)
- [Mullvad WireGuard Guide](https://mullvad.net/en/help/wireguard-and-mullvad-vpn/)
- [Gluetun Mullvad Wiki](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/mullvad.md)

## FAQ

**Q: How many devices can I use with one Mullvad account?**
A: Up to 5 devices simultaneously. You can generate up to 5 WireGuard keys.

**Q: Can I use the same key on multiple devices?**
A: Yes, but it's not recommended for privacy. Each device should have its own key.

**Q: Does Mullvad keep logs?**
A: No, Mullvad has a strict no-logging policy and has been audited to verify this.

**Q: Can I pay anonymously?**
A: Yes, Mullvad accepts cryptocurrency and even cash sent by mail.

**Q: What's the difference between WireGuard and OpenVPN on Mullvad?**
A: WireGuard is faster, more modern, and uses less battery. Mullvad recommends WireGuard.

---

**You're now set up with Mullvad + WireGuard! This is one of the most private and fastest configurations available.**
