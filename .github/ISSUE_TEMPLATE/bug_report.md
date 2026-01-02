---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

## 버그 설명
버그에 대한 명확하고 간결한 설명을 작성하세요.

## 재현 방법
버그를 재현하는 단계:
1. '...'로 이동
2. '....' 클릭
3. '....'까지 스크롤
4. 오류 발생

## 예상 동작
예상했던 동작에 대한 명확하고 간결한 설명을 작성하세요.

## 스크린샷
해당되는 경우 문제를 설명하는 데 도움이 되는 스크린샷을 추가하세요.

## 환경 정보
다음 명령어의 출력을 붙여넣으세요:

```bash
# 운영 체제
uname -a  # Linux/macOS
# 또는 Windows 버전

# Docker 버전
docker version
docker compose version

# 환경 변수 (민감한 정보 제거)
cat .env | sed 's/KEY=.*/KEY=REDACTED/' | sed 's/PASSWORD=.*/PASSWORD=REDACTED/'
```

## 로그
관련 로그를 붙여넣으세요:

```bash
# Gluetun 로그 (마지막 50줄)
docker compose logs --tail=50 gluetun

# qBittorrent 로그 (마지막 50줄)
docker compose logs --tail=50 qbittorrent
```

## 테스트 결과
다음 스크립트의 출력을 붙여넣으세요:

```bash
./scripts/test-vpn.sh
./scripts/health-check.sh
```

## 추가 컨텍스트
문제에 대한 다른 컨텍스트를 여기에 추가하세요.

## 체크리스트
- [ ] [문제 해결 가이드](../docs/troubleshooting.md)를 확인했습니다
- [ ] 기존 이슈에서 중복을 검색했습니다
- [ ] Docker와 Docker Compose가 최신 버전입니다
- [ ] VPN 자격증명이 올바릅니다
- [ ] 로그와 테스트 결과를 포함했습니다
