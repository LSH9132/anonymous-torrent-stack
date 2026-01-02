# CI/CD 가이드

이 문서는 프로젝트의 CI/CD 파이프라인을 설명합니다.

[English](#english) | [한국어](#한국어)

---

## 한국어

### 개요

이 프로젝트는 GitHub Actions를 사용하여 자동화된 CI/CD 파이프라인을 구현합니다.

### 워크플로우

#### 1. CI (Continuous Integration)

**파일**: `.github/workflows/ci.yml`

**트리거**:
- `main`, `develop` 브랜치에 푸시
- `main`, `develop` 브랜치로의 Pull Request

**실행되는 검사**:

1. **Configuration Validation**
   - Docker Compose 구성 검증
   - 환경 변수 검증
   - 스크립트 실행 권한 확인

2. **ShellCheck**
   - 모든 Bash 스크립트 린팅
   - 잠재적 버그 및 개선사항 검출

3. **YAML Lint**
   - YAML 파일 형식 검증
   - 일관성 확인

4. **Setup Test**
   - 디렉토리 구조 생성 테스트
   - .env 파일 생성 테스트

5. **Documentation Check**
   - 필수 문서 존재 확인
   - 한국어 번역 확인

6. **Security Scan**
   - Trivy로 보안 취약점 스캔
   - 구성 파일 보안 검사

#### 2. Release (자동 릴리즈)

**파일**: `.github/workflows/release.yml`

**트리거**:
- `v*.*.*` 형식의 태그 푸시 (예: v1.0.0)

**실행되는 작업**:

1. **버전 추출**
   - 태그에서 버전 번호 추출

2. **Changelog 추출**
   - CHANGELOG.md에서 해당 버전의 내용 추출

3. **GitHub Release 생성**
   - 릴리즈 노트와 함께 Release 생성
   - 자동으로 릴리즈 노트 생성

4. **Discussion 생성** (선택사항)
   - Announcements 카테고리에 릴리즈 공지

#### 3. Auto Tag (자동 버전 태그)

**파일**: `.github/workflows/auto-tag.yml`

**트리거**:
- 수동 실행 (workflow_dispatch)

**입력**:
- **version**: 버전 번호 (예: 1.0.0)
- **release_type**: patch, minor, major

**실행되는 작업**:

1. **버전 계산**
   - 현재 버전 가져오기
   - 새 버전 계산

2. **CHANGELOG 업데이트**
   - Unreleased 섹션을 새 버전으로 변경
   - 비교 링크 업데이트

3. **커밋 및 태그**
   - 변경사항 커밋
   - 새 버전 태그 생성 및 푸시

4. **자동 릴리즈**
   - Release 워크플로우가 자동 실행됨

### 로컬에서 CI 검증

GitHub에 푸시하기 전에 로컬에서 CI 검사를 실행할 수 있습니다:

```bash
./scripts/validate-ci.sh
```

이 스크립트는 다음을 확인합니다:
- Docker Compose 구성
- 환경 변수
- 스크립트 권한
- ShellCheck (설치된 경우)
- YAML 검증 (설치된 경우)
- 필수 문서
- 번역 파일

### 릴리즈 생성 방법

#### 방법 1: 수동 태그 (권장)

```bash
# 새 버전 태그 생성
git tag -a v1.0.0 -m "Release v1.0.0

- Feature A
- Feature B
- Bug fix C"

# 태그 푸시
git push origin v1.0.0
```

#### 방법 2: Auto Tag 워크플로우

1. GitHub → Actions → Auto Tag
2. "Run workflow" 클릭
3. 입력:
   - Version: `1.0.0`
   - Release type: `major`
4. "Run workflow" 클릭

### Semantic Versioning

프로젝트는 [Semantic Versioning](https://semver.org/)을 따릅니다:

- **MAJOR** (1.0.0 → 2.0.0): 호환되지 않는 API 변경
- **MINOR** (1.0.0 → 1.1.0): 하위 호환되는 기능 추가
- **PATCH** (1.0.0 → 1.0.1): 하위 호환되는 버그 수정

### 커밋 메시지 규칙

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: 새 기능
- `fix`: 버그 수정
- `docs`: 문서 변경
- `style`: 코드 포맷팅
- `refactor`: 리팩토링
- `test`: 테스트 추가
- `chore`: 빌드 작업, 설정

**예제**:
```bash
git commit -m "feat(vpn): add Surfshark support

- Add Surfshark configuration
- Update documentation
- Add example .env

Closes #42"
```

### 문제 해결

#### CI 실패: ShellCheck 경고

**문제**: ShellCheck에서 경고 발생

**해결**:
```bash
# ShellCheck 설치 (macOS)
brew install shellcheck

# 스크립트 검사
shellcheck scripts/*.sh

# 경고 수정
```

#### CI 실패: YAML 린트 오류

**문제**: YAML 형식 오류

**해결**:
```bash
# yamllint 설치
pip install yamllint

# YAML 검사
yamllint -c .github/yamllint-config.yml docker-compose.yml .github/workflows/

# 오류 수정 (주로 들여쓰기, 줄 길이)
```

#### Release 생성 안됨

**문제**: 태그를 푸시했지만 릴리즈가 생성되지 않음

**확인**:
1. 태그 형식: `v1.0.0` (v 접두사 필수)
2. GitHub Actions 활성화 확인
3. Workflow 권한 확인 (Settings → Actions)

**재시도**:
```bash
# 태그 삭제
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0

# 다시 생성
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

#### Security Scan 실패

**문제**: Trivy 보안 스캔 실패

**해결**:
- 이것은 경고일 수 있으며 치명적이지 않습니다
- `continue-on-error: true`로 설정되어 있어 CI가 계속 진행됩니다
- 보안 이슈를 검토하고 필요시 수정

### 브랜치 전략

**메인 브랜치**:
- `main`: 안정적인 릴리즈 버전

**개발 브랜치** (선택):
- `develop`: 다음 릴리즈 개발

**기능 브랜치**:
- `feature/<name>`: 새 기능 개발
- `fix/<name>`: 버그 수정
- `docs/<name>`: 문서 업데이트

**워크플로우**:
```bash
# 기능 브랜치 생성
git checkout -b feature/new-vpn-provider

# 작업 및 커밋
git add .
git commit -m "feat: add new VPN provider"

# 푸시
git push origin feature/new-vpn-provider

# GitHub에서 PR 생성
# CI 통과 확인
# Merge
```

### 배지 업데이트

README의 배지는 자동으로 업데이트됩니다:

- **Release**: 새 릴리즈 생성 시 자동 업데이트
- **CI**: CI 워크플로우 실행 시 자동 업데이트
- **Stars/Forks**: GitHub에서 자동 업데이트

### 고급 기능

#### 브랜치 보호

**Settings** → **Branches** → **Branch protection rules**:

`main` 브랜치 보호 권장:
- ✅ Require pull request before merging
- ✅ Require status checks to pass
  - validate
  - shellcheck
  - yaml-lint
- ✅ Require conversation resolution

#### Dependabot (선택)

자동 의존성 업데이트:

1. `.github/dependabot.yml` 생성
2. Docker 이미지 자동 업데이트 설정
3. 주간 PR 자동 생성

#### Scheduled Workflows (선택)

정기적인 검사:

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # 매주 일요일
```

---

## English

### Overview

This project uses GitHub Actions for automated CI/CD pipelines.

### Workflows

#### 1. CI (Continuous Integration)

**File**: `.github/workflows/ci.yml`

**Triggers**:
- Push to `main`, `develop` branches
- Pull Requests to `main`, `develop` branches

**Checks**:

1. **Configuration Validation**
   - Docker Compose validation
   - Environment variables check
   - Script permissions

2. **ShellCheck**
   - Lint all Bash scripts
   - Detect potential bugs

3. **YAML Lint**
   - Validate YAML format
   - Consistency checks

4. **Setup Test**
   - Directory creation test
   - .env file creation test

5. **Documentation Check**
   - Required docs exist
   - Korean translation check

6. **Security Scan**
   - Trivy security scan
   - Configuration security check

#### 2. Release (Automatic)

**File**: `.github/workflows/release.yml`

**Triggers**:
- Tag push with format `v*.*.*` (e.g., v1.0.0)

**Actions**:

1. **Extract Version**
2. **Extract Changelog**
3. **Create GitHub Release**
4. **Create Discussion** (optional)

#### 3. Auto Tag

**File**: `.github/workflows/auto-tag.yml`

**Trigger**: Manual (workflow_dispatch)

**Inputs**:
- **version**: Version number
- **release_type**: patch, minor, major

**Actions**:

1. Calculate new version
2. Update CHANGELOG
3. Commit and create tag
4. Trigger Release workflow

### Local CI Validation

Run CI checks locally before pushing:

```bash
./scripts/validate-ci.sh
```

### Creating Releases

#### Method 1: Manual Tag (Recommended)

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

#### Method 2: Auto Tag Workflow

1. GitHub → Actions → Auto Tag
2. Click "Run workflow"
3. Enter version and type
4. Click "Run workflow"

### Troubleshooting

See above Korean section for detailed troubleshooting steps.

---

## 참고 자료

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

**CI/CD가 완전히 자동화되었습니다!** 🚀

[← 메인으로](../README.ko.md) | [GitHub 설정 가이드 →](github-setup-guide.md)
