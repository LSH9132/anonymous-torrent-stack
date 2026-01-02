# Supported VPN Providers

This stack supports 60+ VPN providers through Gluetun. Below is the complete list with setup information.

## Recommended Providers

### Tier 1 - Best for Privacy & Performance

| Provider | WireGuard | OpenVPN | Port Forwarding | Notes |
|----------|-----------|---------|-----------------|-------|
| **Mullvad** | ✅ | ✅ | ❌ | Best for privacy, accepts cash |
| **ProtonVPN** | ✅ | ✅ | ✅ | Free tier available, port forwarding |
| **IVPN** | ✅ | ✅ | ❌ | Privacy-focused, accepts cash |

### Tier 2 - Good Performance

| Provider | WireGuard | OpenVPN | Port Forwarding | Notes |
|----------|-----------|---------|-----------------|-------|
| **Private Internet Access** | ✅ | ✅ | ✅ | Good speeds, port forwarding |
| **NordVPN** | ✅ | ✅ | ❌ | Large server network |
| **Surfshark** | ❌ | ✅ | ❌ | Unlimited devices |
| **ExpressVPN** | ❌ | ✅ | ❌ | Fast but no WireGuard |

## Complete Provider List

### A-F

- **AirVPN** - OpenVPN, Port forwarding
- **Astrill** - OpenVPN
- **Blackvpn** - OpenVPN
- **Bolehvpn** - OpenVPN
- **Boxpn** - OpenVPN
- **Cryptostorm** - OpenVPN
- **Cyberghost** - WireGuard, OpenVPN
- **ExpressVPN** - OpenVPN
- **Fastestvpn** - OpenVPN
- **FastestVPN** - OpenVPN
- **FrootVPN** - OpenVPN
- **F-Secure** - OpenVPN

### G-P

- **Giganews** - OpenVPN
- **Hide.me** - WireGuard, OpenVPN
- **HideMyAss** - OpenVPN
- **IPVanish** - OpenVPN, WireGuard
- **Ivacy** - OpenVPN
- **IVPN** - WireGuard, OpenVPN
- **Mullvad** - WireGuard, OpenVPN ⭐
- **MozillaVPN** - WireGuard (uses Mullvad)
- **MysteriumVPN** - WireGuard, OpenVPN
- **NordVPN** - WireGuard (NordLynx), OpenVPN
- **Perfect Privacy** - WireGuard, OpenVPN
- **Privado** - OpenVPN
- **Private Internet Access** - WireGuard, OpenVPN, Port forwarding
- **PrivateVPN** - OpenVPN
- **ProtonVPN** - WireGuard, OpenVPN, Port forwarding ⭐
- **PureVPN** - OpenVPN

### S-Z

- **SaferVPN** - OpenVPN
- **SlickVPN** - OpenVPN
- **StrongVPN** - OpenVPN
- **Surfshark** - OpenVPN
- **TorGuard** - OpenVPN
- **Trust.Zone** - OpenVPN
- **VPN Unlimited** - OpenVPN (KeepSolid)
- **VPNSecure** - OpenVPN
- **VPN.ht** - WireGuard, OpenVPN
- **VyprVPN** - WireGuard, OpenVPN
- **WeVPN** - WireGuard, OpenVPN
- **Windscribe** - WireGuard, OpenVPN
- **ZoogVPN** - OpenVPN

### Custom Providers

- **Custom WireGuard** - Any provider with WireGuard support
- **Custom OpenVPN** - Any provider with OpenVPN support

## Configuration Examples

### Built-in Provider (e.g., NordVPN)

```bash
VPN_PROVIDER=nordvpn
VPN_TYPE=openvpn
OPENVPN_USER=your_email
OPENVPN_PASSWORD=your_password
SERVER_COUNTRIES=US
```

### Custom WireGuard Provider

```bash
VPN_PROVIDER=custom
VPN_TYPE=wireguard
# Place wg0.conf in config/vpn/wireguard/
```

### Custom OpenVPN Provider

```bash
VPN_PROVIDER=custom
VPN_TYPE=openvpn
OPENVPN_CUSTOM_CONFIG=/gluetun/custom/vpn.conf
# Place vpn.conf in config/vpn/openvpn/
```

## Provider-Specific Guides

Detailed setup guides are available for:

- [Mullvad + WireGuard](mullvad-wireguard.md) ⭐ Recommended
- [Mullvad + OpenVPN](mullvad-openvpn.md)
- [Custom WireGuard](custom-wireguard.md)
- [Custom OpenVPN](custom-openvpn.md)

## Port Forwarding Support

Only some providers support port forwarding, which improves peer connectivity:

**Supported:**
- Private Internet Access (PIA)
- ProtonVPN
- AirVPN
- Perfect Privacy

**Not Supported:**
- Mullvad (discontinued in 2023)
- NordVPN
- ExpressVPN
- Surfshark

## Choosing a Provider

### For Privacy

1. **Mullvad** - Best overall for privacy
2. **IVPN** - Second best, similar to Mullvad
3. **ProtonVPN** - Good privacy, based in Switzerland

### For Performance

1. **Mullvad** (WireGuard) - Fastest
2. **Private Internet Access** - Good speeds
3. **NordVPN** - Large server network

### For Torrenting

1. **Mullvad** - Privacy + Speed
2. **ProtonVPN** - Free tier + Port forwarding
3. **Private Internet Access** - Port forwarding + Good speeds

### For Budget

1. **ProtonVPN** - Free tier (limited servers)
2. **Mullvad** - €5/month flat rate
3. **Surfshark** - Unlimited devices

## Provider Setup Steps

### 1. Sign Up

Create an account with your chosen provider.

### 2. Get Credentials

**For WireGuard:**
- Download WireGuard config or
- Get private key and addresses from provider dashboard

**For OpenVPN:**
- Download .ovpn file or
- Get username and password

### 3. Configure .env

Update your `.env` file with provider details.

### 4. Start Stack

```bash
docker compose up -d
./scripts/test-vpn.sh
```

## Verification

After setup, always verify your connection:

```bash
./scripts/test-vpn.sh
```

Check:
- ✅ IP address has changed
- ✅ Location matches VPN server
- ✅ DNS leak protection enabled
- ✅ Kill switch active

## Unsupported Providers?

If your provider isn't in the list:

1. **Check for WireGuard or OpenVPN support**
   - Most providers support at least OpenVPN
   - Use custom configuration method

2. **Use Custom Configuration**
   - See [Custom WireGuard Guide](custom-wireguard.md)
   - See [Custom OpenVPN Guide](custom-openvpn.md)

3. **Request Support**
   - Open an issue on [Gluetun GitHub](https://github.com/qdm12/gluetun)
   - Provider support is added regularly

## Additional Resources

- [Gluetun Provider Wiki](https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers)
- [VPN Comparison Chart](https://thatoneprivacysite.net/) (third-party)
- Provider-specific documentation on their websites

## Notes

- **⭐** = Highly recommended
- Provider availability and features subject to change
- Always verify current pricing and features on provider websites
- This project is not affiliated with any VPN provider

---

**Can't decide?** Start with **Mullvad** for the best balance of privacy, performance, and ease of use.
