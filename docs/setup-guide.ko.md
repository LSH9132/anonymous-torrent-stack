# 설치 가이드

이 가이드는 익명 토렌트 스택을 단계별로 설정하는 방법을 안내합니다.

[English](setup-guide.md) | **한국어**

## 목차

- [사전 요구사항](#사전-요구사항)
- [설치](#설치)
- [VPN 제공업체 구성](#vpn-제공업체-구성)
- [스택 시작](#스택-시작)
- [qBittorrent 접속](#qbittorrent-접속)
- [검증](#검증)
- [다음 단계](#다음-단계)

## 사전 요구사항

### 필수 사항

1. **Docker** (버전 20.10 이상)
   - macOS: [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
   - Windows: [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
   - Linux: [Docker Engine](https://docs.docker.com/engine/install/)

2. **Docker Compose** (일반적으로 Docker Desktop에 포함)
   - 버전 확인: `docker compose version`
   - 최소 버전: 1.29.0

3. **활성 VPN 구독**
   - 권장: Mullvad, ProtonVPN, NordVPN 또는 PIA
   - [지원 제공업체](vpn-providers/supported-providers.md) 참조

### 권장 사항

- 기본적인 명령줄 지식
- 텍스트 에디터 (nano, vim 또는 VS Code)
- 다운로드용 여유 디스크 공간 10GB

## 설치

### 1단계: 프로젝트 가져오기

저장소를 클론하거나 소스 코드를 다운로드하세요:

```bash
git clone https://github.com/yourusername/anonymous-torrent-stack.git
cd anonymous-torrent-stack
```

또는 ZIP 파일을 다운로드하고 압축을 푸세요.

### 2단계: 설정 스크립트 실행

설정 스크립트가 초기 구성을 안내합니다:

```bash
./scripts/setup.sh
```

이 스크립트는 다음을 수행합니다:
- Docker 및 Docker Compose 설치 확인
- 템플릿에서 `.env` 파일 생성
- 사용자/그룹 ID 자동 설정
- 시간대 감지
- VPN 제공업체 및 프로토콜 선택 안내
- 포트 설정 구성

**출력 예:**
```
========================================
익명 토렌트 스택 - 설정
========================================

[정보] 사전 요구사항 확인 중...
[성공] Docker가 설치되어 있습니다
[성공] Docker Compose가 설치되어 있습니다
[성공] Docker 데몬이 실행 중입니다
[성공] .env 파일을 생성했습니다
[성공] PUID=1000, PGID=1000 설정
[성공] 시간대를 Asia/Seoul로 설정

========================================
VPN 구성
========================================

VPN 제공업체 이름 입력 (커스텀 구성의 경우 'custom'): mullvad
VPN 프로토콜 선택 (wireguard/openvpn) [wireguard]: wireguard

========================================
포트 구성
========================================

qBittorrent WebUI 포트 구성:
  1. localhost:8080 (권장 - 로컬 접근만)
  2. 8080:8080 (네트워크 접근 가능 - 인증 필요)

옵션 선택 [1]: 1

[성공] 설정 완료!
```

### 3단계: VPN 자격증명 구성

`.env` 파일을 편집하고 VPN 세부정보를 추가하세요:

```bash
nano .env
# 또는
vim .env
# 또는 선호하는 텍스트 에디터로 열기
```

시나리오를 선택하세요:

#### 시나리오 A: Mullvad + WireGuard (권장)

1. [Mullvad](https://mullvad.net/)에 로그인
2. "WireGuard configuration"으로 이동
3. 아직 생성하지 않았다면 WireGuard 키 생성
4. 구성 세부정보 복사

`.env` 업데이트:
```bash
VPN_PROVIDER=mullvad
VPN_TYPE=wireguard
WIREGUARD_PRIVATE_KEY=mullvad에서_복사한_개인키
WIREGUARD_ADDRESSES=mullvad에서_복사한_주소
SERVER_COUNTRIES=SE  # 선택사항: 스웨덴 또는 원하는 국가 코드
```

#### 시나리오 B: 커스텀 WireGuard 제공업체

1. VPN 제공업체에서 WireGuard 구성 다운로드
2. `config/vpn/wireguard/wg0.conf`에 복사
3. `.env` 업데이트:

```bash
VPN_PROVIDER=custom
VPN_TYPE=wireguard
```

[커스텀 WireGuard 가이드](vpn-providers/custom-wireguard.md) 참조

#### 시나리오 C: OpenVPN 제공업체

1. VPN 제공업체에서 OpenVPN 구성(.ovpn 파일) 다운로드
2. `config/vpn/openvpn/custom.conf`에 복사
3. `.env` 업데이트:

```bash
VPN_PROVIDER=custom
VPN_TYPE=openvpn
OPENVPN_CUSTOM_CONFIG=/gluetun/custom/custom.conf
```

또는 내장 제공업체의 경우:
```bash
VPN_PROVIDER=nordvpn  # 또는 protonvpn 등
VPN_TYPE=openvpn
OPENVPN_USER=사용자명
OPENVPN_PASSWORD=비밀번호
SERVER_COUNTRIES=US
```

제공업체별 가이드는 [vpn-providers/](vpn-providers/)를 참조하세요.

## VPN 제공업체 구성

### 내장 제공업체

Gluetun이 지원하는 제공업체(60+)의 경우 `.env`만 구성하면 됩니다:

**예: NordVPN + OpenVPN**
```bash
VPN_PROVIDER=nordvpn
VPN_TYPE=openvpn
OPENVPN_USER=nordvpn_이메일
OPENVPN_PASSWORD=nordvpn_비밀번호
SERVER_COUNTRIES=US,CA  # 미국과 캐나다
```

**예: Private Internet Access + WireGuard**
```bash
VPN_PROVIDER=private internet access
VPN_TYPE=wireguard
WIREGUARD_PRIVATE_KEY=pia_개인키
WIREGUARD_ADDRESSES=pia_주소
VPN_PORT_FORWARDING=on  # PIA는 포트 포워딩 지원
```

### 커스텀 제공업체

VPN 제공업체가 내장되어 있지 않은 경우 커스텀 구성 사용:

1. VPN 구성 파일 가져오기 (WireGuard 또는 OpenVPN)
2. 적절한 디렉토리에 배치:
   - WireGuard: `config/vpn/wireguard/wg0.conf`
   - OpenVPN: `config/vpn/openvpn/custom.conf`
3. `.env`에서 `VPN_PROVIDER=custom` 설정

## 스택 시작

### 첫 시작

1. **분리 모드로 컨테이너 시작:**

```bash
docker compose up -d
```

2. **시작을 모니터링하기 위해 로그 확인:**

```bash
docker compose logs -f
```

다음을 확인해야 합니다:
- Gluetun이 VPN 서버에 연결
- qBittorrent가 Gluetun의 정상 상태 대기
- VPN 연결 수립 후 qBittorrent 시작

**Ctrl+C를 눌러 로그 보기 중지** (컨테이너는 계속 실행됩니다)

### 예상 시작 순서

1. **Gluetun 시작** (10-30초)
   ```
   gluetun | INFO [dns over tls] using plaintext DNS at address 1.1.1.1:53
   gluetun | INFO [vpn] starting
   gluetun | INFO [vpn] connected
   gluetun | INFO [healthcheck] program has been running for 31s
   ```

2. **Gluetun이 정상 상태로 변경** (VPN 연결 성공 후)
   ```
   gluetun | INFO [healthcheck] healthy!
   ```

3. **qBittorrent 시작** (Gluetun 헬스 체크 대기)
   ```
   qbittorrent | **************************************
   qbittorrent | Web UI는 http://localhost:8080에서 접근 가능합니다
   qbittorrent | **************************************
   ```

### 시작 확인

컨테이너 상태 확인:
```bash
docker compose ps
```

예상 출력:
```
NAME          STATUS                    PORTS
gluetun       Up 2 minutes (healthy)    127.0.0.1:8000->8000/tcp, 127.0.0.1:8080->8080/tcp
qbittorrent   Up 1 minute
```

## qBittorrent 접속

### Web UI 열기

브라우저에서 이동: [http://localhost:8080](http://localhost:8080)

### 기본 인증 정보

- **사용자명:** `admin`
- **비밀번호:** `adminadmin`

### 첫 로그인 단계

1. **기본 인증 정보로 로그인**

2. **즉시 비밀번호 변경:**
   - 도구 → 옵션 → Web UI로 이동
   - 인증 섹션
   - 새 사용자명과 비밀번호 입력
   - "저장" 클릭

3. **선택사항: 추가 설정 구성:**
   - 다운로드 → 저장 경로: `/downloads` (이미 구성됨)
   - 연결 → 수신 포트: 사용 가능한 경우 포워딩된 포트 사용
   - BitTorrent → 프라이버시 → 익명 모드 활성화
   - BitTorrent → 암호화: 암호화 필수

## 검증

### VPN 연결 테스트

테스트 스크립트 실행:

```bash
./scripts/test-vpn.sh
```

다음을 확인합니다:
- ✓ VPN 연결 상태
- ✓ 공용 IP (실제 IP와 달라야 함)
- ✓ DNS 유출 방지
- ✓ 킬 스위치 기능
- ✓ qBittorrent WebUI 접근성

**예상 출력:**
```
========================================
VPN 연결 테스트
========================================

[✓] 컨테이너가 실행 중입니다
[✓] VPN IP 주소: 185.65.134.66
[✓] 위치: Stockholm, Sweden
[✓] VPN이 작동합니다! IP가 숨겨졌습니다.
[✓] DNS가 Gluetun의 DoT를 사용합니다
[✓] VPN 연결이 활성화되어 있습니다
[✓] qBittorrent WebUI가 http://localhost:8080에서 접근 가능합니다
[✓] 모든 테스트 완료!
```

### 수동 검증

1. **qBittorrent를 통해 공용 IP 확인:**
   - qBittorrent에서 테스트 토렌트 추가 (예: Ubuntu ISO)
   - [iknowwhatyoudownload.com](https://iknowwhatyoudownload.com/)과 같은 사이트 방문
   - 실제 IP가 아닌 VPN IP가 표시되는지 확인

2. **킬 스위치 테스트:**
   ```bash
   # Gluetun 중지
   docker stop gluetun

   # qBittorrent WebUI 접근 시도 - 실패해야 함
   curl http://localhost:8080
   # 예상: 연결 거부 또는 시간 초과

   # Gluetun 재시작
   docker start gluetun

   # 30초 대기 후 접근이 다시 작동해야 함
   ```

3. **DNS 유출 테스트:**
   ```bash
   # 사용 중인 DNS 서버 확인
   docker exec gluetun cat /etc/resolv.conf
   # 127.0.0.1이 표시되어야 함 (Gluetun의 DoT)
   ```

## 다음 단계

### 포트 포워딩 구성 (선택사항)

VPN 제공업체가 포트 포워딩을 지원하는 경우(PIA, ProtonVPN):

1. `.env`에서 활성화:
   ```bash
   VPN_PORT_FORWARDING=on
   ```

2. 컨테이너 재시작:
   ```bash
   docker compose down
   docker compose up -d
   ```

3. 포워딩된 포트 확인:
   ```bash
   curl http://localhost:8000/v1/openvpn/portforwarded
   ```

4. qBittorrent에서 구성:
   - 도구 → 옵션 → 연결
   - 수신 포트: 포워딩된 포트 번호 사용
   - "UPnP/NAT-PMP 사용" 체크 해제

### 네트워크 접근 (선택사항)

네트워크의 다른 장치에서 qBittorrent에 접근하려면:

1. `.env` 업데이트:
   ```bash
   QBITTORRENT_PORT=8080:8080
   ```

2. 재시작:
   ```bash
   docker compose down
   docker compose up -d
   ```

3. 다른 장치에서 접근:
   ```
   http://YOUR_COMPUTER_IP:8080
   ```

**보안 참고:** 기본 비밀번호를 변경했는지 확인하세요!

### 헬스 모니터링 설정

스택의 상태 모니터링:

```bash
# 일회성 확인
./scripts/health-check.sh

# 지속적인 모니터링 (30초마다)
watch -n 30 ./scripts/health-check.sh
```

### 다운로드 카테고리 구성

qBittorrent에서:
1. 도구 → 옵션 → 다운로드
2. "토렌트의 레이블을 저장 경로에 추가" → 활성화
3. 더 나은 구성을 위한 카테고리 생성

### RSS 피드 추가 (선택사항)

1. 보기 → RSS 리더 → 활성화
2. 선호하는 토렌트 사이트의 RSS 피드 추가
3. 자동 다운로드 규칙 설정

## 일반적인 문제

### Gluetun이 시작되지 않음

**증상:** Gluetun 컨테이너가 즉시 종료되거나 재시작 반복

**해결:**
1. 로그 확인: `docker compose logs gluetun`
2. `.env`의 자격증명 확인
3. 다른 서버 시도: `SERVER_COUNTRIES=US`
4. [문제 해결 가이드](troubleshooting.md) 확인

### qBittorrent가 "오프라인"으로 표시됨

**증상:** qBittorrent WebUI에 접근할 수 없음

**해결:**
1. 시작 후 60초 대기
2. Gluetun이 정상인지 확인: `docker compose ps`
3. 포트 바인딩 확인: `docker compose ps | grep 8080`
4. qBittorrent 로그 확인: `docker compose logs qbittorrent`

### VPN 연결되었지만 IP가 동일함

**증상:** IP가 변경되지 않음

**해결:**
1. 실행: `./scripts/test-vpn.sh`
2. 연결 오류에 대한 Gluetun 로그 확인
3. VPN 자격증명이 올바른지 확인
4. 다른 VPN 서버 위치 시도

### 권한 오류

**증상:** 다운로드 폴더에 쓸 수 없음

**해결:**
1. `.env`의 PUID/PGID가 사용자와 일치하는지 확인:
   ```bash
   id -u  # UID 가져오기
   id -g  # GID 가져오기
   ```
2. 올바른 값으로 `.env` 업데이트
3. 재시작: `docker compose down && docker compose up -d`

## 추가 리소스

- [VPN 제공업체 가이드](vpn-providers/) - 제공업체별 설정
- [문제 해결](troubleshooting.md) - 일반적인 문제 및 해결책
- [고급 구성](advanced-configuration.md) - 파워 유저 기능
- [Gluetun Wiki](https://github.com/qdm12/gluetun-wiki) - 공식 Gluetun 문서

## 지원

문제가 발생하면:

1. [문제 해결 가이드](troubleshooting.md) 확인
2. 컨테이너 로그 검토: `docker compose logs`
3. 테스트 스크립트 실행: `./scripts/test-vpn.sh`
4. 기존 GitHub 이슈 검색
5. 다음을 포함하여 새 GitHub 이슈 생성:
   - `.env` 구성 (민감한 데이터 제거!)
   - 컨테이너 로그
   - 테스트 스크립트 출력

---

**축하합니다!** 이제 VPN 보호 및 킬 스위치가 있는 완전히 작동하는 익명 토렌트 스택이 있습니다. 즐거운 (합법적인) 토렌트 다운로드 하세요!

[← 메인으로 돌아가기](../README.ko.md) | [문제 해결 →](troubleshooting.md)
