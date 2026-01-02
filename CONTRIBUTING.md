# 기여 가이드

Anonymous Torrent Stack에 기여해주셔서 감사합니다! 🎉

## 기여 방법

### 버그 리포트

버그를 발견하셨나요? 다음 단계를 따라주세요:

1. **기존 이슈 확인**: [Issues](../../issues)에서 동일한 버그가 이미 보고되었는지 확인하세요.
2. **새 이슈 생성**: 없다면 [Bug Report 템플릿](.github/ISSUE_TEMPLATE/bug_report.md)을 사용하여 새 이슈를 생성하세요.
3. **세부 정보 포함**:
   - 재현 단계
   - 예상 동작 vs 실제 동작
   - 환경 정보 (OS, Docker 버전 등)
   - 관련 로그
   - 스크린샷 (해당되는 경우)

### 기능 제안

새로운 기능에 대한 아이디어가 있으신가요?

1. **기존 요청 확인**: 이미 제안되었는지 확인하세요.
2. **Feature Request 생성**: [Feature Request 템플릿](.github/ISSUE_TEMPLATE/feature_request.md)을 사용하세요.
3. **명확하게 설명**:
   - 해결하려는 문제
   - 제안하는 솔루션
   - 사용 사례
   - 가능한 구현 방법

### Pull Request 제출

코드 기여를 환영합니다! 다음 프로세스를 따라주세요:

#### 1. Fork 및 Clone

```bash
# 저장소 Fork (GitHub에서)
# 그런 다음 clone
git clone https://github.com/your-username/anonymous-torrent-stack.git
cd anonymous-torrent-stack
```

#### 2. 브랜치 생성

```bash
# 설명적인 이름의 브랜치 생성
git checkout -b feature/your-feature-name
# 또는
git checkout -b fix/bug-description
```

#### 3. 변경 사항 작성

**코드 스타일:**
- 기존 코드 스타일과 일관성 유지
- 의미 있는 변수 및 함수 이름 사용
- 복잡한 로직에 주석 추가

**Docker Compose:**
- YAML 들여쓰기: 2 스페이스
- 논리적 순서로 서비스 구성
- 환경 변수에 설명 주석 추가

**Bash 스크립트:**
- ShellCheck로 검증
- 오류 처리 포함 (`set -e`)
- 명확한 출력 메시지 제공

**문서:**
- 한국어와 영어 모두 업데이트
- Markdown 형식 준수
- 예제 포함

#### 4. 테스트

변경 사항을 테스트하세요:

```bash
# 설정 스크립트 테스트
./scripts/setup.sh

# VPN 연결 테스트
./scripts/test-vpn.sh

# 헬스 체크 테스트
./scripts/health-check.sh

# 실제 사용 시나리오 테스트
docker compose up -d
# WebUI 접속, 토렌트 추가 등
```

#### 5. Commit

명확한 커밋 메시지 작성:

```bash
git add .
git commit -m "feat: add support for custom DNS providers

- Add DOT_CUSTOM_PROVIDERS env variable
- Update docker-compose.yml with DNS config
- Add documentation for custom DNS setup
- Update test-vpn.sh to verify DNS settings"
```

**커밋 메시지 규칙:**
- `feat:` 새로운 기능
- `fix:` 버그 수정
- `docs:` 문서만 변경
- `style:` 코드 의미에 영향을 주지 않는 변경
- `refactor:` 버그 수정이나 기능 추가가 아닌 코드 변경
- `test:` 테스트 추가 또는 수정
- `chore:` 빌드 프로세스나 도구 변경

#### 6. Push 및 PR 생성

```bash
git push origin feature/your-feature-name
```

그런 다음 GitHub에서 Pull Request를 생성하세요.

**PR 설명에 포함:**
- 변경 사항 요약
- 관련 이슈 참조 (`Fixes #123`)
- 테스트 방법
- 스크린샷 (UI 변경인 경우)
- 체크리스트:
  - [ ] 로컬에서 테스트 완료
  - [ ] 문서 업데이트 (필요한 경우)
  - [ ] 한국어 문서 업데이트 (필요한 경우)
  - [ ] 기존 테스트 통과
  - [ ] 새 기능에 대한 테스트 추가 (해당되는 경우)

### 문서 기여

문서 개선도 환영합니다!

**문서 파일:**
- `README.md` - 영문 메인 문서
- `README.ko.md` - 한글 메인 문서
- `docs/setup-guide.md` - 설치 가이드
- `docs/troubleshooting.md` - 문제 해결
- `docs/advanced-configuration.md` - 고급 설정
- `docs/vpn-providers/*.md` - VPN 제공업체별 가이드

**문서 작성 가이드라인:**
- 명확하고 간결하게 작성
- 단계별 지침 제공
- 코드 예제 포함
- 스크린샷 추가 (유용한 경우)
- 한국어와 영어 모두 업데이트

### 번역

한국어 ↔ 영어 번역 기여를 환영합니다!

1. 번역이 필요한 파일 확인
2. 정확하고 자연스러운 번역 제공
3. 기술 용어의 일관성 유지
4. 문화적 맥락 고려

## 코드 리뷰 프로세스

1. **자동 검사**: PR이 제출되면 자동 검사가 실행됩니다
2. **리뷰어 검토**: 프로젝트 관리자가 코드를 검토합니다
3. **피드백**: 변경이 필요하면 코멘트를 남깁니다
4. **승인**: 모든 것이 좋으면 PR이 병합됩니다

**리뷰 시간:**
- 일반적으로 2-3일 이내
- 긴급한 버그 수정: 24시간 이내
- 대규모 기능: 최대 1주일

## 개발 환경 설정

### 필요 도구

```bash
# Docker 및 Docker Compose
docker --version
docker compose version

# 텍스트 에디터
# VS Code, vim, nano 등

# Git
git --version

# ShellCheck (스크립트 린팅)
shellcheck --version
```

### 로컬 테스트 환경

```bash
# 저장소 클론
git clone https://github.com/your-username/anonymous-torrent-stack.git
cd anonymous-torrent-stack

# .env 파일 생성
cp .env.example .env
nano .env  # VPN 자격증명 입력

# 테스트 실행
docker compose up -d
./scripts/test-vpn.sh
```

## 코드 스타일 가이드

### Bash 스크립트

```bash
#!/bin/bash

# 스크립트 설명
# 사용법: ./script.sh

set -e  # 오류 시 종료

# 변수명: UPPER_CASE 또는 lower_case
CONST_VALUE="constant"
local_var="variable"

# 함수
function_name() {
    local param=$1
    echo "Processing: $param"
}

# 오류 처리
if ! command -v docker &> /dev/null; then
    echo "Error: Docker not found"
    exit 1
fi
```

### YAML (Docker Compose)

```yaml
version: "3.8"

services:
  service_name:
    image: image:tag
    container_name: container_name
    environment:
      - VAR_NAME=${VAR_NAME}  # 환경 변수 사용
      - ANOTHER_VAR=value     # 하드코딩 값
    volumes:
      - ./local:/container
    restart: unless-stopped
    networks:
      - network_name
```

### Markdown

```markdown
# 제목 1

간단한 설명.

## 제목 2

### 제목 3

**굵게** 또는 *기울임*

- 목록 항목 1
- 목록 항목 2

1. 순서 목록 1
2. 순서 목록 2

코드 블록:
```bash
command here
```

링크: [텍스트](URL)
```

## 커뮤니티 가이드라인

### 행동 강령

- **존중**: 모든 기여자를 존중하세요
- **건설적**: 건설적인 피드백을 제공하세요
- **협력적**: 함께 더 나은 프로젝트를 만듭니다
- **인내심**: 초보자에게 친절하게 대하세요

### 금지 사항

- 공격적이거나 모욕적인 언어
- 개인 정보 공개
- 스팸 또는 광고
- 불법 활동 장려

## 질문이 있으신가요?

- **일반 질문**: [Discussions](../../discussions) 사용
- **버그**: [Issues](../../issues) 생성
- **보안 문제**: 비공개로 보고 (이메일)

## 라이선스

기여함으로써 귀하의 기여가 프로젝트와 동일한 [MIT 라이선스](LICENSE)에 따라 라이선스됨에 동의합니다.

---

**다시 한 번 감사드립니다!** 🙏

귀하의 기여는 이 프로젝트를 모두를 위해 더 좋게 만듭니다.
