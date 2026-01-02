# Custom OpenVPN Provider Setup

This guide helps you configure any VPN provider that supports OpenVPN, even if it's not built into Gluetun.

⚠️ **Recommendation**: If your provider supports WireGuard, use [Custom WireGuard](custom-wireguard.md) instead for better performance.

## When to Use Custom OpenVPN

- Your VPN provider isn't in the [supported list](supported-providers.md)
- Provider's built-in support isn't working
- You need TCP mode (restrictive networks)
- Provider only supports OpenVPN

## Prerequisites

- OpenVPN configuration file (.ovpn) from your VPN provider
- OR OpenVPN credentials (username/password + server details)

## Setup Method

### Step 1: Get OpenVPN Configuration

Download the .ovpn file from your VPN provider's website.

It should look like:
```
client
dev tun
proto udp
remote vpn.example.com 1194
auth-user-pass
...
```

### Step 2: Place Config File

```bash
# Copy your .ovpn file to the config directory
cp ~/Downloads/provider.ovpn config/vpn/openvpn/custom.conf
```

### Step 3: Configure .env

```bash
VPN_PROVIDER=custom
VPN_TYPE=openvpn
OPENVPN_CUSTOM_CONFIG=/gluetun/custom/custom.conf

# If your config has auth-user-pass (most do):
OPENVPN_USER=your_username
OPENVPN_PASSWORD=your_password
```

### Step 4: Start and Test

```bash
docker compose up -d
./scripts/test-vpn.sh
```

## Configuration Examples

### Example 1: Simple Config with Credentials

**custom.conf:**
```
client
dev tun
proto udp
remote vpn.example.com 1194
resolv-retry infinite
nobind
persist-key
persist-tun
auth SHA256
cipher AES-256-CBC
verb 3

<ca>
-----BEGIN CERTIFICATE-----
...certificate here...
-----END CERTIFICATE-----
</ca>
```

**.env:**
```bash
VPN_PROVIDER=custom
VPN_TYPE=openvpn
OPENVPN_CUSTOM_CONFIG=/gluetun/custom/custom.conf
OPENVPN_USER=myusername
OPENVPN_PASSWORD=mypassword
```

### Example 2: Config with Embedded Credentials

Some providers give you a config with embedded credentials. You can keep those in the file:

**custom.conf:**
```
...
<auth-user-pass>
username
password
</auth-user-pass>
...
```

Then you don't need `OPENVPN_USER` and `OPENVPN_PASSWORD` in .env.

### Example 3: TCP Mode (for restrictive networks)

If UDP is blocked, use TCP:

**custom.conf:**
```
client
dev tun
proto tcp  # Changed from udp
remote vpn.example.com 443  # Often uses port 443 for TCP
...
```

## Troubleshooting

### Connection Fails

1. **Check logs:**
   ```bash
   docker compose logs gluetun | grep -i openvpn
   ```

2. **Verify config file:**
   ```bash
   cat config/vpn/openvpn/custom.conf | head -20
   ```

3. **Test on host first:**
   ```bash
   sudo openvpn --config config/vpn/openvpn/custom.conf
   # Press Ctrl+C to stop
   ```

### Authentication Failed

- Verify username/password in .env
- Check if provider requires special credentials for OpenVPN
- Some providers use account number instead of email

### TLS Errors

If you see TLS handshake errors:

1. Check certificate in config file
2. Verify server address is correct
3. Try different server from provider

### DNS Leaks

Gluetun handles DNS automatically with DoT. To verify:
```bash
./scripts/test-vpn.sh
```

## Converting .ovpn Files

Some providers give you .ovpn files with special formatting. If Gluetun won't accept it:

1. **Remove Windows line endings:**
   ```bash
   dos2unix config/vpn/openvpn/custom.conf
   ```

2. **Check for inline credentials:**
   - Look for `<auth-user-pass>` blocks
   - Either use them or remove and use .env variables

3. **Verify certificates:**
   - `<ca>`, `<cert>`, `<key>` blocks should be intact

## Security Considerations

### Credential Storage

Never commit credentials to version control:
```bash
# .gitignore already protects you
grep openvpn .gitignore
```

### Certificate Verification

Always verify `remote-cert-tls server` is in your config:
```bash
grep remote-cert-tls config/vpn/openvpn/custom.conf
```

## Advanced Options

### Multiple Configs

To switch between servers, create multiple configs:
```bash
config/vpn/openvpn/
  ├── us-server.conf
  ├── eu-server.conf
  └── asia-server.conf
```

Then in .env:
```bash
OPENVPN_CUSTOM_CONFIG=/gluetun/custom/us-server.conf
```

### Port Selection

Some providers offer multiple ports:
- UDP 1194 (default, fastest)
- UDP 53 (DNS port, bypasses some firewalls)
- TCP 443 (HTTPS port, works almost everywhere)
- TCP 80 (HTTP port, last resort)

Update `remote` line in your config:
```
remote vpn.example.com 443
proto tcp
```

### Compression

Some older configs use compression. Modern practice is to disable it:
```
# Remove or comment out:
# comp-lzo
# compress

# Add:
compress  # No compression
```

## Provider-Specific Notes

### Using Provider's App Config

Many providers let you export OpenVPN configs from their app:

1. Install provider's app
2. Export OpenVPN config
3. Copy to `config/vpn/openvpn/custom.conf`
4. Follow setup steps above

### Multi-Hop Configs

Some providers support multi-hop (VPN chaining). These configs work but may be slower.

## Testing

1. **Start the stack:**
   ```bash
   docker compose up -d
   ```

2. **Monitor connection:**
   ```bash
   docker compose logs -f gluetun
   # Wait for "Initialization Sequence Completed"
   ```

3. **Run test:**
   ```bash
   ./scripts/test-vpn.sh
   ```

4. **Verify:**
   - IP should be different
   - Location should match VPN server
   - DNS should use DoT

## Performance Tips

### Use UDP When Possible

UDP is faster than TCP:
```
proto udp
remote vpn.example.com 1194
```

### Disable Unnecessary Options

Remove unused options for faster connection:
```
# Remove these if present:
# comp-lzo
# fragment
# mssfix
```

### Choose Nearby Servers

Select geographically close servers for best speed.

## Migration to WireGuard

If your provider supports WireGuard, consider migrating:

**Advantages:**
- 3-4x faster
- Better battery life
- Modern cryptography
- Simpler configuration

See [Custom WireGuard Guide](custom-wireguard.md)

## Additional Resources

- [OpenVPN Documentation](https://openvpn.net/community-resources/)
- [Gluetun Custom Provider Wiki](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/custom.md)
- [Troubleshooting Guide](../troubleshooting.md)

---

**Having issues?** Test your OpenVPN config on your host machine first with `sudo openvpn --config your-config.ovpn` to isolate problems.
