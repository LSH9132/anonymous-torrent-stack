# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- GitHub Actions CI/CD workflows
- Automated testing
- Docker Hub automated builds
- Additional VPN provider guides
- Video tutorials
- Grafana dashboard templates

## [1.0.0] - 2026-01-02

### Added
- Initial release
- Docker Compose stack with Gluetun VPN and qBittorrent
- Support for 60+ VPN providers through Gluetun
- WireGuard and OpenVPN protocol support
- Triple-layer kill switch (network isolation + firewall + DNS)
- DNS over TLS (DoT) for leak prevention
- Automatic VPN reconnection with escalating timeouts
- Health monitoring with built-in checks
- Interactive setup script (`scripts/setup.sh`)
- VPN connection test script (`scripts/test-vpn.sh`)
- Health check monitoring script (`scripts/health-check.sh`)
- Comprehensive documentation:
  - English README
  - Korean README (README.ko.md)
  - Detailed setup guide
  - Troubleshooting guide
  - Advanced configuration guide
  - VPN provider-specific guides:
    - Mullvad WireGuard
    - Mullvad OpenVPN
    - Custom WireGuard
    - Custom OpenVPN
    - Supported providers list
- Configuration templates:
  - WireGuard config example
  - OpenVPN config example
  - Comprehensive .env.example with 200+ lines
- Port forwarding support for compatible providers (PIA, ProtonVPN, etc.)
- Customizable DNS providers (Cloudflare, Quad9, Google)
- Network access options (localhost-only or LAN-accessible)
- Security features:
  - Container isolation
  - Firewall rules
  - DNS leak protection
  - Minimal privilege model
- Easy extensibility (Jackett, Radarr, Sonarr compatible)
- MIT License
- Contributing guidelines
- GitHub issue templates
- .gitignore for security

### Security
- Triple-layer kill switch ensures no IP leaks
- DNS over TLS prevents ISP tracking
- All credentials stored in .env (git-ignored)
- Minimal container capabilities (NET_ADMIN only)
- Network isolation at Docker level
- Firewall-enforced VPN-only traffic

### Documentation
- Complete English documentation (~3000+ lines)
- Complete Korean documentation
- Step-by-step setup guides
- Provider-specific instructions
- Troubleshooting for common issues
- Advanced configuration examples
- FAQ section
- Code examples throughout

---

## Version History

### Legend
- `Added` - New features
- `Changed` - Changes in existing functionality
- `Deprecated` - Soon-to-be removed features
- `Removed` - Removed features
- `Fixed` - Bug fixes
- `Security` - Vulnerability fixes

---

## Future Roadmap

### Version 1.1.0 (Planned)
- [ ] Automated Docker image builds
- [ ] Pre-configured provider templates
- [ ] Web-based configuration UI
- [ ] Monitoring dashboard (Prometheus + Grafana)
- [ ] Automatic port forwarding sync with qBittorrent
- [ ] Multi-container VPN failover
- [ ] Additional language support (Japanese, Chinese)

### Version 1.2.0 (Planned)
- [ ] Integration with *arr stack (Radarr, Sonarr, etc.)
- [ ] Automated backup/restore scripts
- [ ] Docker Swarm support
- [ ] Kubernetes manifests
- [ ] Enhanced logging and metrics
- [ ] Performance optimization guides

### Version 2.0.0 (Future)
- [ ] Complete web UI for management
- [ ] Mobile app for remote management
- [ ] Built-in speed testing
- [ ] Automated VPN server selection
- [ ] Advanced traffic routing
- [ ] Integrated ad-blocking

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute to this project.

## Upgrade Notes

### From 0.x to 1.0.0
This is the initial release. No upgrade path needed.

---

[Unreleased]: https://github.com/yourusername/anonymous-torrent-stack/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/anonymous-torrent-stack/releases/tag/v1.0.0
