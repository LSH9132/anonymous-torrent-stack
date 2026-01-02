# Custom WireGuard Provider Setup

This guide helps you configure any VPN provider that supports WireGuard, even if it's not built into Gluetun.

## When to Use Custom Configuration

- Your VPN provider isn't in the [supported list](supported-providers.md)
- You want to use a specific WireGuard server
- Provider's built-in support isn't working
- You have your own WireGuard server

## Prerequisites

- WireGuard configuration file (.conf) from your VPN provider
- OR WireGuard credentials (private key, addresses, etc.)

## Method 1: Using Gluetun's Custom WireGuard (Recommended)

### Step 1: Get WireGuard Configuration

Download or create a WireGuard configuration file from your VPN provider. It should look like:

```ini
[Interface]
PrivateKey = YOUR_PRIVATE_KEY
Address = 10.x.x.x/32
DNS = 10.64.0.1

[Peer]
PublicKey = SERVER_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0, ::0/0
Endpoint = SERVER_IP:PORT
PersistentKeepalive = 25
```

### Step 2: Extract Configuration Details

From your WireGuard config, extract:

- **PrivateKey** - Your client's private key
- **Address** - Your assigned IP address(es)
- **PublicKey** (in [Peer] section) - Server's public key
- **Endpoint** - Server IP and port

### Step 3: Configure .env

Update your `.env` file:

```bash
# VPN Configuration
VPN_PROVIDER=custom
VPN_TYPE=wireguard

# WireGuard Details (from your config file)
WIREGUARD_PRIVATE_KEY=your_private_key_here
WIREGUARD_ADDRESSES=10.x.x.x/32  # Can include IPv6: 10.x.x.x/32,fc00::x/128

# Server Details
WIREGUARD_PUBLIC_KEY=server_public_key_here
WIREGUARD_ENDPOINT_IP=server.vpn.com  # Or IP address
WIREGUARD_ENDPOINT_PORT=51820  # Usually 51820, check your config
```

### Step 4: Start and Test

```bash
docker compose up -d
./scripts/test-vpn.sh
```

## Method 2: Using Config File

If you prefer to use the full .conf file:

### Step 1: Place Config File

```bash
# Copy your WireGuard config
cp ~/Downloads/myprovider.conf config/vpn/wireguard/wg0.conf
```

### Step 2: Minimal .env Configuration

```bash
VPN_PROVIDER=custom
VPN_TYPE=wireguard
```

**Note:** Gluetun will automatically read `wg0.conf` from the mounted directory.

### Step 3: Start and Test

```bash
docker compose up -d
./scripts/test-vpn.sh
```

## Example Configurations

### Example 1: Generic VPN Provider

```bash
# .env
VPN_PROVIDER=custom
VPN_TYPE=wireguard
WIREGUARD_PRIVATE_KEY=aBcDeFgHiJkLmNoPqRsTuVwXyZ0123456789+/ABCDEFGH=
WIREGUARD_ADDRESSES=10.128.45.123/32
WIREGUARD_PUBLIC_KEY=xYzAbC123456789+/DeF=
WIREGUARD_ENDPOINT_IP=vpn.example.com
WIREGUARD_ENDPOINT_PORT=51820
```

### Example 2: Self-Hosted WireGuard Server

```bash
# .env
VPN_PROVIDER=custom
VPN_TYPE=wireguard
WIREGUARD_PRIVATE_KEY=your_client_private_key
WIREGUARD_ADDRESSES=10.0.0.2/32
WIREGUARD_PUBLIC_KEY=your_server_public_key
WIREGUARD_ENDPOINT_IP=your.server.ip
WIREGUARD_ENDPOINT_PORT=51820
```

### Example 3: Provider with Multiple Endpoints

Create `config/vpn/wireguard/wg0.conf`:

```ini
[Interface]
PrivateKey = YOUR_PRIVATE_KEY
Address = 10.8.0.2/32

[Peer]
PublicKey = SERVER_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0
Endpoint = server1.vpn.com:51820

# Failover to second server
[Peer]
PublicKey = SERVER2_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0
Endpoint = server2.vpn.com:51820
```

## Troubleshooting

### Connection Fails

1. **Verify credentials:**
   ```bash
   cat .env | grep WIREGUARD
   ```

2. **Check Gluetun logs:**
   ```bash
   docker compose logs gluetun | grep -i wireguard
   ```

3. **Test endpoint reachability:**
   ```bash
   ping your_endpoint_ip
   ```

4. **Verify port is correct:**
   - Default WireGuard port: 51820
   - Some providers use different ports

### Invalid Key Errors

WireGuard keys are base64-encoded and end with `=`. Example:
```
aBcDeFgHiJkLmNoPqRsTuVwXyZ0123456789+/ABCDEFGH=
```

Check:
- ✅ No extra spaces
- ✅ Ends with `=`
- ✅ Correct length (44 characters)
- ✅ Only contains: A-Z, a-z, 0-9, +, /, =

### Address Format Issues

Addresses must include CIDR notation:

```bash
# Correct
WIREGUARD_ADDRESSES=10.8.0.2/32

# Wrong
WIREGUARD_ADDRESSES=10.8.0.2
```

Multiple addresses (IPv4 + IPv6):
```bash
WIREGUARD_ADDRESSES=10.8.0.2/32,fc00:bbbb:bbbb:bb01::2/128
```

### DNS Issues

By default, Gluetun handles DNS with DoT. If you need custom DNS:

```bash
# In .env
DOT=off  # Disable DoT (not recommended)
```

Then add DNS to your wg0.conf:
```ini
[Interface]
DNS = 10.64.0.1
```

## Security Considerations

### Keep Your Private Key Secret

Never share or commit your private key:
```bash
# .gitignore already excludes .env and config files
cat .gitignore
```

### Rotate Keys Regularly

Generate new WireGuard keys periodically:
1. Generate new key pair with your VPN provider
2. Update .env or wg0.conf
3. Restart: `docker compose restart gluetun`

### Verify Connection

Always verify you're actually using the VPN:
```bash
./scripts/test-vpn.sh
```

## Advanced Options

### PreShared Keys

If your provider uses preshared keys (PSK):

Add to `wg0.conf`:
```ini
[Peer]
PublicKey = SERVER_PUBLIC_KEY
PresharedKey = YOUR_PRESHARED_KEY
AllowedIPs = 0.0.0.0/0
Endpoint = server.vpn.com:51820
```

### Custom MTU

If you experience connection issues:

```ini
[Interface]
MTU = 1420  # Default
# or
MTU = 1380  # For problematic networks
```

### Multiple Peers

Some setups use multiple peers for redundancy:

```ini
[Interface]
PrivateKey = YOUR_KEY
Address = 10.8.0.2/32

[Peer]
PublicKey = PRIMARY_SERVER
Endpoint = primary.vpn.com:51820
AllowedIPs = 0.0.0.0/0

[Peer]
PublicKey = BACKUP_SERVER
Endpoint = backup.vpn.com:51820
AllowedIPs = 0.0.0.0/0
```

## Provider Examples

### Cloudflare WARP

```bash
VPN_PROVIDER=custom
VPN_TYPE=wireguard
# Get credentials from WARP app
```

### Other Common Providers

Most providers give you a .conf file:
1. Download it
2. Copy to `config/vpn/wireguard/wg0.conf`
3. Set `VPN_PROVIDER=custom` and `VPN_TYPE=wireguard`

## Testing

1. **Start the stack:**
   ```bash
   docker compose up -d
   ```

2. **Check logs:**
   ```bash
   docker compose logs gluetun
   ```

3. **Run test:**
   ```bash
   ./scripts/test-vpn.sh
   ```

4. **Verify IP changed:**
   - Should show VPN server's IP
   - Location should match server location

## Getting Help

If you're stuck:

1. Check WireGuard config syntax
2. Verify all credentials are correct
3. Test VPN config on your host machine first
4. Check provider documentation
5. See [troubleshooting guide](../troubleshooting.md)

## Additional Resources

- [WireGuard Official Documentation](https://www.wireguard.com/)
- [Gluetun Custom Provider Wiki](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/custom.md)
- Provider's WireGuard setup guide

---

**Need help?** Make sure your WireGuard config works on your host machine first before trying it in Docker.
