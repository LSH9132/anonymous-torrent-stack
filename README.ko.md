# 익명 토렌트 스택

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/v/release/LSH9132/anonymous-torrent-stack)](https://github.com/LSH9132/anonymous-torrent-stack/releases)
[![CI](https://github.com/LSH9132/anonymous-torrent-stack/workflows/CI/badge.svg)](https://github.com/LSH9132/anonymous-torrent-stack/actions/workflows/ci.yml)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![WireGuard](https://img.shields.io/badge/WireGuard-88171A?logo=wireguard&logoColor=white)](https://www.wireguard.com/)

[![GitHub stars](https://img.shields.io/github/stars/LSH9132/anonymous-torrent-stack?style=social)](https://github.com/LSH9132/anonymous-torrent-stack/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/LSH9132/anonymous-torrent-stack?style=social)](https://github.com/LSH9132/anonymous-torrent-stack/network/members)

[English](README.md) | **한국어**

</div>

---

VPN (WireGuard/OpenVPN)을 사용한 익명 토렌트 다운로드를 위한 Docker 기반 솔루션입니다. 자동 킬 스위치, DNS 유출 방지, 60개 이상의 VPN 제공업체를 지원합니다.

## 주요 기능

### 보안 및 프라이버시
- **3중 킬 스위치**: 네트워크 격리 + 방화벽 규칙 + DNS 보호
- **DNS 유출 방지**: DNS over TLS (DoT)로 ISP 추적 차단
- **IP 유출 없음**: 모든 토렌트 트래픽이 VPN을 통해서만 전송
- **다중 제공업체 지원**: Mullvad, ProtonVPN, NordVPN, PIA 등 60개 이상 지원
- **프로토콜 유연성**: WireGuard (권장) 또는 OpenVPN 지원

### 안정성
- **자동 재연결**: 점진적 재시도 타임아웃으로 VPN 자동 재연결
- **헬스 모니터링**: VPN과 토렌트 클라이언트의 내장 상태 확인
- **컨테이너 격리**: Docker 레벨 네트워크 보안으로 유출 방지
- **우아한 실패 처리**: VPN 실패 시 qBittorrent 자동 중지

### 사용 편의성
- **5분 설정**: 자동화된 설정 스크립트와 대화형 구성
- **간단한 설정**: 환경 변수 기반 설정
- **테스트 스크립트**: 내장 VPN 연결 및 유출 테스트 도구
- **포괄적인 문서**: 모든 VPN 제공업체에 대한 단계별 가이드

## 아키텍처

```
┌─────────────────────────────────────────┐
│           Docker 호스트 네트워크          │
│  ┌────────────────────────────────────┐ │
│  │      Gluetun (VPN 컨테이너)        │ │
│  │  ┌──────────────────────────────┐  │ │
│  │  │  VPN 터널 (WireGuard/OVPN)   │  │ │
│  │  │  ┌────────────────────────┐  │  │ │
│  │  │  │   qBittorrent 클라이언트│ │  │ │
│  │  │  │  (network_mode: gluetun)│ │  │ │
│  │  │  └────────────────────────┘  │  │ │
│  │  │   킬 스위치: 3중 보호        │  │ │
│  │  └──────────────────────────────┘  │ │
│  │  포트: 8080 (WebUI), 8000 (API)   │ │
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**작동 원리:**
1. Gluetun이 VPN 제공업체와 VPN 연결 수립
2. qBittorrent가 `network_mode: service:gluetun`을 사용하여 Gluetun의 네트워크 공유
3. 모든 qBittorrent 트래픽이 Gluetun의 VPN 터널을 통과해야 함
4. VPN 연결이 끊기면 qBittorrent는 모든 네트워크 접근 권한을 잃음 (킬 스위치)

## 빠른 시작

### 사전 요구사항
- Docker 및 Docker Compose 설치
- 활성 VPN 구독 (Mullvad, ProtonVPN, NordVPN 등)
- 5분의 시간

### 설치

1. **저장소 클론 또는 다운로드**
   ```bash
   git clone https://github.com/LSH9132/anonymous-torrent-stack.git
   cd anonymous-torrent-stack
   ```

2. **설정 스크립트 실행**
   ```bash
   ./scripts/setup.sh
   ```
   이 스크립트는 `.env` 파일을 생성하고 기본 설정을 구성합니다.

3. **VPN 자격증명 구성**

   `.env` 파일을 편집하고 VPN 세부정보를 추가하세요:

   **옵션 A: Mullvad + WireGuard (권장)**
   ```bash
   VPN_PROVIDER=mullvad
   VPN_TYPE=wireguard
   WIREGUARD_PRIVATE_KEY=여기에_개인키_입력
   WIREGUARD_ADDRESSES=여기에_주소_입력
   SERVER_COUNTRIES=SE
   ```

   **옵션 B: 커스텀 WireGuard 제공업체**
   ```bash
   VPN_PROVIDER=custom
   VPN_TYPE=wireguard
   # wg0.conf 파일을 config/vpn/wireguard/에 배치
   ```

   **옵션 C: 커스텀 OpenVPN 제공업체**
   ```bash
   VPN_PROVIDER=custom
   VPN_TYPE=openvpn
   OPENVPN_CUSTOM_CONFIG=/gluetun/custom/your-config.conf
   # .ovpn 파일을 config/vpn/openvpn/에 배치
   ```

   제공업체별 가이드는 [docs/vpn-providers/](docs/vpn-providers/)를 참조하세요.

4. **스택 시작**
   ```bash
   docker compose up -d
   ```

5. **연결 테스트**
   ```bash
   ./scripts/test-vpn.sh
   ```

6. **qBittorrent 접속**

   [http://localhost:8080](http://localhost:8080)을 여세요

   기본 인증 정보:
   - 사용자명: `admin`
   - 비밀번호: `adminadmin`

   **⚠️ 첫 로그인 후 즉시 변경하세요!**

## VPN 제공업체 설정

### 지원 제공업체 (60개 이상)

이 스택은 Gluetun을 통해 60개 이상의 VPN 제공업체를 즉시 지원합니다:

**인기 제공업체:**
- Mullvad (프라이버시에 권장)
- ProtonVPN
- NordVPN
- Private Internet Access (PIA)
- ExpressVPN
- Surfshark
- Windscribe
- IPVanish
- 그 외 다수...

전체 목록은 [docs/vpn-providers/supported-providers.md](docs/vpn-providers/supported-providers.md)를 참조하세요.

### 빠른 설정 가이드

- [Mullvad + WireGuard](docs/vpn-providers/mullvad-wireguard.md) ⭐ 권장
- [Mullvad + OpenVPN](docs/vpn-providers/mullvad-openvpn.md)
- [커스텀 WireGuard](docs/vpn-providers/custom-wireguard.md)
- [커스텀 OpenVPN](docs/vpn-providers/custom-openvpn.md)

## 구성

### 포트 구성

**로컬호스트 전용 (기본 - 권장)**
```bash
QBITTORRENT_PORT=127.0.0.1:8080
```
WebUI를 로컬 컴퓨터에서만 접근 가능.

**네트워크 접근 가능**
```bash
QBITTORRENT_PORT=8080:8080
```
네트워크의 다른 장치에서 WebUI 접근 가능. 강력한 비밀번호를 설정하세요!

### 고급 기능

#### 포트 포워딩

일부 VPN 제공업체(PIA, ProtonVPN)는 더 나은 피어 연결성을 위한 포트 포워딩을 지원합니다:

```bash
VPN_PORT_FORWARDING=on
```

포워딩된 포트가 자동으로 감지되며 향상된 다운로드/업로드 속도를 위해 qBittorrent에서 구성할 수 있습니다.

#### 커스텀 DNS 제공업체

```bash
DOT_PROVIDERS=cloudflare  # 기본값
# 또는: quad9, google, quadrant
```

#### 방화벽 구성

로컬 네트워크 접근 허용 (WebUI용):
```bash
FIREWALL_OUTBOUND_SUBNETS=192.168.1.0/24,172.20.0.0/16
```

## 사용법

### 스택 시작
```bash
docker compose up -d
```

### 스택 중지
```bash
docker compose down
```

### 로그 보기
```bash
# 모든 로그
docker compose logs -f

# Gluetun만
docker compose logs -f gluetun

# qBittorrent만
docker compose logs -f qbittorrent
```

### 헬스 체크
```bash
./scripts/health-check.sh

# 지속적인 모니터링 (30초마다)
watch -n 30 ./scripts/health-check.sh
```

### VPN 연결 테스트
```bash
./scripts/test-vpn.sh
```

이 스크립트는 다음을 확인합니다:
- VPN 연결 상태
- 공용 IP (실제 IP와 달라야 함)
- DNS 유출 방지
- 킬 스위치 상태
- qBittorrent WebUI 접근성

## 보안 기능

### 킬 스위치 (3중 보호)

1. **네트워크 격리 (주 보호)**
   - `network_mode: service:gluetun`은 qBittorrent가 Gluetun을 통해서만 통신하도록 보장
   - Gluetun이 중지되거나 충돌하면 qBittorrent는 모든 네트워크 접근을 잃음
   - Docker 레벨 강제 적용 (가장 신뢰할 수 있는 방법)

2. **방화벽 규칙 (2차 보호)**
   - Gluetun의 내장 iptables 규칙이 VPN이 아닌 모든 트래픽 차단
   - WebUI용 로컬 네트워크 접근 허용 구성 가능
   - VPN 터널이 다운되면 모든 트래픽 차단

3. **DNS 유출 방지 (3차 보호)**
   - DNS over TLS (DoT)가 모든 DNS 쿼리 암호화
   - 모든 DNS 트래픽이 Cloudflare/Quad9를 통과
   - VPN 터널이 수립될 때까지 DNS 비활성화
   - ISP로의 일반 DNS 쿼리 없음

### 검증

킬 스위치가 작동하는지 확인하려면:

1. 스택을 시작하고 qBittorrent WebUI가 접근 가능한지 확인
2. Gluetun 중지: `docker stop gluetun`
3. qBittorrent WebUI 접근 시도 - 실패해야 함
4. Gluetun 시작: `docker start gluetun`
5. WebUI가 약 30초 후 다시 작동해야 함

## 문제 해결

### VPN이 연결되지 않음

1. `.env`에서 자격증명 확인
2. Gluetun 로그 보기: `docker compose logs gluetun`
3. 다른 서버 시도: `SERVER_COUNTRIES=US` (국가 코드 변경)
4. [docs/troubleshooting.md](docs/troubleshooting.md) 참조

### WebUI에 접근할 수 없음

1. 시작 후 30-60초 대기 (서비스 초기화 필요)
2. 컨테이너가 실행 중인지 확인: `docker ps`
3. Gluetun이 정상인지 확인: `docker compose ps`
4. 포트 바인딩 확인: `.env`의 `QBITTORRENT_PORT=127.0.0.1:8080`

### IP가 변경되지 않음

1. `./scripts/test-vpn.sh`를 실행하여 VPN 연결 확인
2. Gluetun 로그에서 연결 오류 확인
3. VPN 자격증명이 올바른지 확인
4. 다른 VPN 서버/위치 시도

더 많은 문제는 [docs/troubleshooting.md](docs/troubleshooting.md)를 참조하세요.

## 프로젝트 구조

```
anonymous-torrent-stack/
├── docker-compose.yml          # 메인 Docker Compose 구성
├── .env.example                # 환경 변수 템플릿
├── .gitignore                  # Git 무시 규칙
├── README.md                   # 영문 문서
├── README.ko.md                # 한글 문서 (이 파일)
├── LICENSE                     # MIT 라이선스
├── config/
│   ├── gluetun/               # Gluetun 구성 (자동 생성)
│   ├── qbittorrent/           # qBittorrent 구성 (자동 생성)
│   └── vpn/
│       ├── wireguard/         # 커스텀 WireGuard 구성
│       │   └── wg0.conf.example
│       └── openvpn/           # 커스텀 OpenVPN 구성
│           └── custom.conf.example
├── data/
│   ├── qbittorrent/           # qBittorrent 앱 데이터
│   └── downloads/             # 다운로드된 파일
├── scripts/
│   ├── setup.sh               # 대화형 설정 스크립트
│   ├── test-vpn.sh            # VPN 연결 테스터
│   └── health-check.sh        # 헬스 모니터링 스크립트
└── docs/
    ├── setup-guide.md         # 상세 설치 지침
    ├── troubleshooting.md     # 일반적인 문제 및 해결책
    ├── advanced-configuration.md  # 고급 주제
    └── vpn-providers/         # 제공업체별 가이드
        ├── mullvad-wireguard.md
        ├── mullvad-openvpn.md
        ├── custom-wireguard.md
        ├── custom-openvpn.md
        └── supported-providers.md
```

## 문서

- [설정 가이드](docs/setup-guide.md) - 상세 설치 지침
- [문제 해결](docs/troubleshooting.md) - 일반적인 문제 및 해결책
- [고급 구성](docs/advanced-configuration.md) - 포트 포워딩, 커스텀 DNS, 성능 튜닝
- [VPN 제공업체 가이드](docs/vpn-providers/) - 제공업체별 지침

## 스택 확장

이 아키텍처는 VPN을 사용하는 추가 서비스를 쉽게 추가할 수 있습니다:

```yaml
services:
  # ... 기존 gluetun 및 qbittorrent 서비스 ...

  jackett:
    image: lscr.io/linuxserver/jackett:latest
    container_name: jackett
    network_mode: "service:gluetun"  # VPN을 통해 라우팅
    depends_on:
      gluetun:
        condition: service_healthy
    # ... 기타 구성 ...
```

인기 있는 추가 서비스:
- **Jackett/Prowlarr**: 토렌트 인덱서 집계
- **Radarr/Sonarr**: 자동화된 영화/TV 쇼 관리
- **Grafana/Prometheus**: 모니터링 및 대시보드
- **Tautulli**: Plex 미디어 서버 통계

## 자주 묻는 질문

**Q: 어떤 VPN 제공업체를 추천하나요?**
A: Mullvad는 프라이버시와 성능의 균형이 뛰어나며 WireGuard와 OpenVPN을 모두 지원합니다. ProtonVPN도 무료 티어 옵션이 있어 좋은 선택입니다.

**Q: WireGuard가 OpenVPN보다 나은가요?**
A: 예, WireGuard는 일반적으로 더 빠르고, 더 안전하며, 최신 암호화를 사용하고, 구성이 더 간단하기 때문에 권장됩니다.

**Q: 무료 VPN을 사용할 수 있나요?**
A: 기술적으로는 가능하지만, 무료 VPN은 종종 대역폭 제한, 낮은 성능, 의심스러운 프라이버시 관행을 가지고 있습니다. 유료 VPN을 강력히 권장합니다.

**Q: 다운로드가 느려지나요?**
A: VPN 암호화 오버헤드로 인해 일반적으로 10-30% 속도 감소가 있습니다. WireGuard가 OpenVPN보다 빠릅니다. 실제 속도는 VPN 제공업체의 서버 품질에 따라 다릅니다.

**Q: 이것은 합법인가요?**
A: VPN과 토렌트 클라이언트 사용은 대부분의 국가에서 합법입니다. 그러나 저작권이 있는 콘텐츠를 허가 없이 다운로드하는 것은 많은 관할권에서 불법입니다. 이 도구는 합법적인 토렌트 사용 전용입니다.

**Q: 휴대폰/태블릿에서 WebUI에 접근할 수 있나요?**
A: 예! `.env`에서 `QBITTORRENT_PORT=8080:8080`으로 설정하여 네트워크 접근을 활성화하세요. 강력한 비밀번호를 사용해야 합니다.

## 기여

기여를 환영합니다! 이슈나 풀 리퀘스트를 자유롭게 제출해주세요.

## 라이선스

MIT 라이선스 - 자세한 내용은 [LICENSE](LICENSE)를 참조하세요.

## 면책 조항

이 프로젝트는 교육 목적 및 합법적 사용 전용입니다. 개발자는 이 소프트웨어의 오용에 대해 책임지지 않습니다. 항상 저작권법과 VPN 제공업체의 서비스 약관을 준수하세요.

## 감사의 말

- [Gluetun](https://github.com/qdm12/gluetun) - @qdm12의 뛰어난 VPN 클라이언트 컨테이너
- [qBittorrent](https://www.qbittorrent.org/) - 자유 오픈 소스 토렌트 클라이언트
- [LinuxServer.io](https://www.linuxserver.io/) - 고품질 Docker 이미지

---

**⭐ 이 프로젝트가 유용하다면 GitHub에 별을 주는 것을 고려해주세요!**

질문이나 문제가 있으면 [docs/troubleshooting.md](docs/troubleshooting.md)를 참조하거나 GitHub에서 이슈를 여세요.
