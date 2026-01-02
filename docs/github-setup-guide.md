# GitHub 저장소 설정 가이드

이 가이드는 Anonymous Torrent Stack을 GitHub에 올리고 모든 기능을 활성화하는 방법을 설명합니다.

[English](#english-version) | [한국어](#한국어-버전)

---

## 한국어 버전

### 목차
- [1단계: GitHub 저장소 생성](#1단계-github-저장소-생성)
- [2단계: 로컬 저장소 설정](#2단계-로컬-저장소-설정)
- [3단계: 첫 커밋 및 푸시](#3단계-첫-커밋-및-푸시)
- [4단계: 저장소 설정](#4단계-저장소-설정)
- [5단계: GitHub Actions 설정](#5단계-github-actions-설정)
- [6단계: 첫 릴리즈 생성](#6단계-첫-릴리즈-생성)
- [7단계: 고급 기능 설정](#7단계-고급-기능-설정)
- [문제 해결](#문제-해결)

---

### 1단계: GitHub 저장소 생성

#### 1.1 GitHub에 로그인
1. [GitHub](https://github.com)에 로그인
2. 우측 상단 `+` 클릭 → `New repository` 선택

#### 1.2 저장소 정보 입력

**Repository name:**
```
anonymous-torrent-stack
```

**Description:**
```
🔒 Docker-based anonymous torrenting with VPN kill switch. Supports 60+ providers (Mullvad, ProtonVPN, NordVPN), WireGuard/OpenVPN, DNS leak protection, and auto-reconnect. 5-min setup!
```

**설정:**
- ✅ Public (또는 Private - 선택)
- ❌ Initialize this repository with a README (이미 있음)
- ❌ Add .gitignore (이미 있음)
- ❌ Choose a license (이미 있음)

**Create repository** 클릭

---

### 2단계: 로컬 저장소 설정

#### 2.1 저장소 상태 확인

```bash
cd /Users/lsh/anonymous-torrent-stack

# Git 상태 확인
git status

# 현재 브랜치 확인
git branch
```

#### 2.2 사용자명 수정

README 파일의 `yourusername`을 실제 GitHub 사용자명으로 변경:

```bash
# macOS
find . -name "*.md" -type f -exec sed -i '' 's/yourusername/YOUR_GITHUB_USERNAME/g' {} +
find . -name "*.yml" -type f -exec sed -i '' 's/yourusername/YOUR_GITHUB_USERNAME/g' {} +

# Linux
find . -name "*.md" -type f -exec sed -i 's/yourusername/YOUR_GITHUB_USERNAME/g' {} +
find . -name "*.yml" -type f -exec sed -i 's/yourusername/YOUR_GITHUB_USERNAME/g' {} +
```

**`YOUR_GITHUB_USERNAME`을 실제 GitHub 사용자명으로 변경하세요!**

---

### 3단계: 첫 커밋 및 푸시

#### 3.1 Git 사용자 정보 설정 (처음 한 번만)

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### 3.2 모든 파일 추가 및 커밋

```bash
# 모든 파일 스테이징
git add .

# 커밋
git commit -m "Initial commit: Anonymous Torrent Stack v1.0.0

- Complete Docker Compose setup with Gluetun + qBittorrent
- Support for 60+ VPN providers (WireGuard/OpenVPN)
- Triple-layer kill switch and DNS leak protection
- Comprehensive English and Korean documentation
- Automated setup, testing, and health monitoring scripts
- VPN provider-specific guides
- GitHub Actions CI/CD workflows
- Issue templates and contributing guidelines

🤖 Generated with Claude Code (https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

#### 3.3 원격 저장소 추가 및 푸시

```bash
# 원격 저장소 추가 (GitHub 저장소 URL로 변경)
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/anonymous-torrent-stack.git

# 브랜치 이름 확인 및 변경
git branch -M main

# 푸시
git push -u origin main
```

**성공 메시지가 표시되면 1단계 완료!** ✅

---

### 4단계: 저장소 설정

#### 4.1 About 섹션 설정

1. GitHub 저장소 페이지로 이동
2. 우측 상단 톱니바퀴 ⚙️ 클릭 (About 옆)
3. **Description** 입력:
   ```
   🔒 Docker-based anonymous torrenting with VPN kill switch. Supports 60+ providers, WireGuard/OpenVPN, DNS leak protection. 5-min setup!
   ```

4. **Website** (선택사항):
   ```
   https://mullvad.net
   ```
   또는 프로젝트 문서 페이지

5. **Topics** 추가 (최대 20개):
   ```
   docker
   docker-compose
   vpn
   torrent
   qbittorrent
   gluetun
   wireguard
   openvpn
   privacy
   anonymity
   kill-switch
   dns-leak-protection
   mullvad
   protonvpn
   nordvpn
   self-hosted
   automation
   security
   networking
   linux
   ```

6. **Save changes** 클릭

#### 4.2 Features 활성화

저장소 **Settings** → **General** → **Features**:

- ✅ **Issues** - 활성화 (버그 리포트용)
- ✅ **Discussions** - 활성화 (커뮤니티 Q&A용)
- ❌ **Projects** - 비활성화 (필요시 활성화)
- ❌ **Wiki** - 비활성화 (docs/ 폴더 사용)

**Save** 클릭

#### 4.3 Pull Requests 설정

**Settings** → **General** → **Pull Requests**:

- ✅ **Allow merge commits**
- ✅ **Allow squash merging**
- ✅ **Allow rebase merging**
- ✅ **Automatically delete head branches**

**Save** 클릭

---

### 5단계: GitHub Actions 설정

#### 5.1 Actions 활성화

**Settings** → **Actions** → **General**:

- **Actions permissions**: ✅ **Allow all actions and reusable workflows**
- **Workflow permissions**: ✅ **Read and write permissions**
- ✅ **Allow GitHub Actions to create and approve pull requests**

**Save** 클릭

#### 5.2 Secrets 설정 (선택사항)

**Settings** → **Secrets and variables** → **Actions**:

Discussions 자동 생성을 위한 설정 (선택사항):

1. **New repository secret** 클릭
2. 다음 시크릿 추가:

**REPOSITORY_ID** (선택사항):
```bash
# GitHub GraphQL로 저장소 ID 가져오기
# https://docs.github.com/en/graphql/guides/forming-calls-with-graphql
```

**ANNOUNCEMENTS_CATEGORY_ID** (선택사항):
```bash
# Discussions 카테고리 ID
```

> **참고**: 이 시크릿들은 선택사항입니다. 없어도 릴리즈는 정상 작동합니다.

#### 5.3 첫 워크플로우 실행 확인

**Actions** 탭으로 이동:

- `CI` 워크플로우가 자동으로 실행되어야 합니다
- 모든 체크가 ✅ 통과하는지 확인
- 실패하면 로그를 확인하고 수정

---

### 6단계: 첫 릴리즈 생성

#### 방법 1: 수동 태그 생성 (권장 - 첫 릴리즈용)

```bash
# v1.0.0 태그 생성
git tag -a v1.0.0 -m "Release v1.0.0

Initial release with complete Docker stack for anonymous torrenting.

Features:
- Docker Compose setup with Gluetun + qBittorrent
- 60+ VPN providers support
- Triple-layer kill switch
- DNS leak protection
- Automated scripts and comprehensive documentation

🤖 Generated by GitHub Actions"

# 태그 푸시
git push origin v1.0.0
```

**GitHub Actions가 자동으로 릴리즈를 생성합니다!**

#### 방법 2: GitHub Actions로 자동 태그 생성

1. GitHub 저장소 → **Actions** 탭
2. 왼쪽에서 **Auto Tag** 워크플로우 선택
3. **Run workflow** 클릭
4. 입력:
   - **Version**: `1.0.0`
   - **Release type**: `major`
5. **Run workflow** 클릭

**워크플로우가 자동으로 태그와 릴리즈를 생성합니다!**

#### 6.1 릴리즈 확인

1. **Releases** 탭으로 이동
2. **v1.0.0** 릴리즈 확인
3. Release notes 확인
4. 필요시 편집 가능

---

### 7단계: 고급 기능 설정

#### 7.1 Discussions 카테고리 설정

**Discussions** 탭 → **Categories**:

기본 카테고리:
- 📢 **Announcements** - 릴리즈 및 공지사항
- 💡 **Ideas** - 기능 제안
- 🙏 **Q&A** - 질문과 답변
- 💬 **General** - 일반 토론

새 카테고리 추가:
1. **New category** 클릭
2. 예: "VPN Providers" (VPN 제공업체별 토론)
3. 예: "Troubleshooting" (문제 해결 토론)

#### 7.2 Issue Labels 설정

**Issues** → **Labels**:

기본 라벨 외 추가 권장:
- `vpn` - VPN 관련 이슈
- `qbittorrent` - qBittorrent 관련
- `docker` - Docker 관련
- `documentation` - 문서 관련
- `good first issue` - 초보자 친화적 이슈
- `help wanted` - 도움 필요
- `question` - 질문
- `wontfix` - 수정하지 않음

#### 7.3 프로젝트 보호 설정 (선택사항)

**Settings** → **Branches** → **Branch protection rules**:

`main` 브랜치 보호:
1. **Add rule** 클릭
2. **Branch name pattern**: `main`
3. 설정:
   - ✅ **Require a pull request before merging**
   - ✅ **Require status checks to pass before merging**
     - 선택: `validate`, `shellcheck`, `yaml-lint`
   - ✅ **Require conversation resolution before merging**
4. **Create** 클릭

#### 7.4 Social Preview 이미지 (선택사항)

프로젝트를 더 돋보이게 하려면 소셜 프리뷰 이미지 생성:

1. [Canva](https://www.canva.com/) 또는 Figma로 이미지 생성
   - 크기: 1280x640px
   - 내용: 프로젝트 이름, 로고, 주요 기능
2. **Settings** → **General** → **Social preview**
3. **Upload an image** 클릭
4. 생성한 이미지 업로드

---

### 추가 릴리즈 생성하기

#### 자동 버전 증가 (권장)

1. **Actions** → **Auto Tag**
2. **Run workflow** 클릭
3. 릴리즈 타입 선택:
   - **patch**: 1.0.0 → 1.0.1 (버그 수정)
   - **minor**: 1.0.0 → 1.1.0 (새 기능)
   - **major**: 1.0.0 → 2.0.0 (큰 변경)
4. **Run workflow** 클릭

#### 수동 태그 생성

```bash
# 새 버전 태그 생성
git tag -a v1.1.0 -m "Release v1.1.0

New features:
- Added XYZ
- Improved ABC

Bug fixes:
- Fixed issue #123

🤖 Generated by GitHub Actions"

# 태그 푸시
git push origin v1.1.0
```

---

### Git 전략

#### 브랜치 전략

**메인 브랜치:**
- `main` - 안정적인 릴리즈 버전

**개발 브랜치 (선택사항):**
- `develop` - 다음 릴리즈 개발

**기능 브랜치:**
- `feature/new-vpn-provider` - 새 기능
- `fix/bug-123` - 버그 수정
- `docs/setup-guide` - 문서 업데이트

#### 워크플로우

1. **새 기능 개발**:
   ```bash
   git checkout -b feature/my-feature
   # 작업...
   git add .
   git commit -m "feat: add new feature"
   git push origin feature/my-feature
   ```

2. **Pull Request 생성**:
   - GitHub에서 PR 생성
   - CI 통과 확인
   - 리뷰 받기
   - Merge

3. **릴리즈**:
   - CHANGELOG.md 업데이트
   - Auto Tag 워크플로우 실행
   - 자동으로 릴리즈 생성됨

#### 커밋 메시지 규칙

```
<type>: <subject>

<body>

<footer>
```

**Types:**
- `feat:` - 새 기능
- `fix:` - 버그 수정
- `docs:` - 문서 변경
- `style:` - 코드 포맷팅
- `refactor:` - 리팩토링
- `test:` - 테스트 추가
- `chore:` - 빌드 작업, 설정 변경

**예제:**
```bash
git commit -m "feat: add Surfshark VPN support

- Add Surfshark to supported providers
- Update documentation
- Add example configuration

Closes #42"
```

---

### 문제 해결

#### CI 워크플로우 실패

**문제**: Actions에서 CI가 실패함

**해결**:
1. **Actions** 탭에서 실패한 워크플로우 클릭
2. 빨간색 X가 있는 작업 클릭
3. 로그 확인
4. 오류 수정 후 푸시

**일반적인 오류:**
- ShellCheck 경고: 스크립트 수정
- YAML 린트 오류: YAML 형식 수정
- 링크 오류: 깨진 링크 수정

#### Release 워크플로우가 실행되지 않음

**문제**: 태그를 푸시했지만 릴리즈가 생성되지 않음

**확인**:
1. 태그 형식: `v1.0.0` (v 접두사 필수)
2. Actions 활성화 확인
3. 워크플로우 권한 확인

**재시도**:
```bash
# 태그 삭제
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0

# 다시 생성
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

#### 배지가 표시되지 않음

**문제**: README의 배지가 404 오류

**해결**:
1. `yourusername`을 실제 사용자명으로 변경 확인
2. 저장소가 Public인지 확인
3. Actions가 한 번 이상 실행되었는지 확인

#### Discussions가 보이지 않음

**문제**: Discussions 탭이 없음

**해결**:
1. **Settings** → **General** → **Features**
2. **Discussions** 체크 확인
3. 페이지 새로고침

---

### 유용한 명령어

#### Git 상태 확인
```bash
git status
git log --oneline --graph --all -10
git tag -l
```

#### 원격 저장소 동기화
```bash
git fetch --all --tags
git pull origin main
```

#### 태그 관리
```bash
# 모든 태그 보기
git tag

# 특정 태그 정보
git show v1.0.0

# 로컬 태그 삭제
git tag -d v1.0.0

# 원격 태그 삭제
git push origin :refs/tags/v1.0.0
```

#### 브랜치 관리
```bash
# 모든 브랜치 보기
git branch -a

# 새 브랜치 생성 및 전환
git checkout -b feature/new-feature

# 브랜치 병합
git checkout main
git merge feature/new-feature

# 브랜치 삭제
git branch -d feature/new-feature
```

---

### 다음 단계

프로젝트를 공유하세요:

1. **커뮤니티**:
   - Reddit: r/selfhosted, r/VPN
   - Hacker News
   - 개발 커뮤니티 (클리앙, 뽐뿌 등)

2. **블로그**:
   - 기술 블로그에 소개글 작성
   - Medium 또는 Dev.to에 게시

3. **소셜 미디어**:
   - Twitter/X로 공유
   - LinkedIn에 포스팅

4. **지속적 개선**:
   - 이슈 응답
   - PR 리뷰
   - 정기적 업데이트
   - 커뮤니티 피드백 수렴

---

## English Version

### Table of Contents
- [Step 1: Create GitHub Repository](#step-1-create-github-repository)
- [Step 2: Local Repository Setup](#step-2-local-repository-setup)
- [Step 3: First Commit and Push](#step-3-first-commit-and-push)
- [Step 4: Repository Settings](#step-4-repository-settings)
- [Step 5: GitHub Actions Setup](#step-5-github-actions-setup)
- [Step 6: Create First Release](#step-6-create-first-release)
- [Step 7: Advanced Features](#step-7-advanced-features)
- [Troubleshooting](#troubleshooting-1)

---

### Step 1: Create GitHub Repository

#### 1.1 Login to GitHub
1. Go to [GitHub](https://github.com) and login
2. Click `+` in top right → Select `New repository`

#### 1.2 Enter Repository Information

**Repository name:**
```
anonymous-torrent-stack
```

**Description:**
```
🔒 Docker-based anonymous torrenting with VPN kill switch. Supports 60+ providers (Mullvad, ProtonVPN, NordVPN), WireGuard/OpenVPN, DNS leak protection, and auto-reconnect. 5-min setup!
```

**Settings:**
- ✅ Public (or Private - your choice)
- ❌ Initialize this repository with a README (already exists)
- ❌ Add .gitignore (already exists)
- ❌ Choose a license (already exists)

Click **Create repository**

---

### Step 2: Local Repository Setup

#### 2.1 Check Repository Status

```bash
cd /Users/lsh/anonymous-torrent-stack

# Check Git status
git status

# Check current branch
git branch
```

#### 2.2 Update Username

Replace `yourusername` with your actual GitHub username in all files:

```bash
# macOS
find . -name "*.md" -type f -exec sed -i '' 's/yourusername/YOUR_GITHUB_USERNAME/g' {} +
find . -name "*.yml" -type f -exec sed -i '' 's/yourusername/YOUR_GITHUB_USERNAME/g' {} +

# Linux
find . -name "*.md" -type f -exec sed -i 's/yourusername/YOUR_GITHUB_USERNAME/g' {} +
find . -name "*.yml" -type f -exec sed -i 's/yourusername/YOUR_GITHUB_USERNAME/g' {} +
```

**Replace `YOUR_GITHUB_USERNAME` with your actual GitHub username!**

---

### Step 3: First Commit and Push

#### 3.1 Configure Git User Info (first time only)

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### 3.2 Add and Commit All Files

```bash
# Stage all files
git add .

# Commit
git commit -m "Initial commit: Anonymous Torrent Stack v1.0.0

- Complete Docker Compose setup with Gluetun + qBittorrent
- Support for 60+ VPN providers (WireGuard/OpenVPN)
- Triple-layer kill switch and DNS leak protection
- Comprehensive English and Korean documentation
- Automated setup, testing, and health monitoring scripts
- VPN provider-specific guides
- GitHub Actions CI/CD workflows
- Issue templates and contributing guidelines

🤖 Generated with Claude Code (https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

#### 3.3 Add Remote and Push

```bash
# Add remote repository (change to your GitHub repository URL)
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/anonymous-torrent-stack.git

# Rename branch to main
git branch -M main

# Push
git push -u origin main
```

**Step 1 complete if you see success message!** ✅

---

### Step 4: Repository Settings

#### 4.1 Configure About Section

1. Go to GitHub repository page
2. Click ⚙️ next to About (top right)
3. Enter **Description**:
   ```
   🔒 Docker-based anonymous torrenting with VPN kill switch. Supports 60+ providers, WireGuard/OpenVPN, DNS leak protection. 5-min setup!
   ```

4. **Website** (optional):
   ```
   https://mullvad.net
   ```

5. Add **Topics** (up to 20):
   ```
   docker, docker-compose, vpn, torrent, qbittorrent, gluetun,
   wireguard, openvpn, privacy, anonymity, kill-switch,
   dns-leak-protection, mullvad, protonvpn, nordvpn,
   self-hosted, automation, security, networking, linux
   ```

6. Click **Save changes**

#### 4.2 Enable Features

Repository **Settings** → **General** → **Features**:

- ✅ **Issues**
- ✅ **Discussions**
- ❌ **Projects**
- ❌ **Wiki**

Click **Save**

#### 4.3 Pull Request Settings

**Settings** → **General** → **Pull Requests**:

- ✅ **Allow merge commits**
- ✅ **Allow squash merging**
- ✅ **Allow rebase merging**
- ✅ **Automatically delete head branches**

Click **Save**

---

### Step 5: GitHub Actions Setup

#### 5.1 Enable Actions

**Settings** → **Actions** → **General**:

- **Actions permissions**: ✅ **Allow all actions and reusable workflows**
- **Workflow permissions**: ✅ **Read and write permissions**
- ✅ **Allow GitHub Actions to create and approve pull requests**

Click **Save**

#### 5.2 CI Workflow Verification

Go to **Actions** tab:

- `CI` workflow should run automatically
- Verify all checks pass ✅
- If failed, check logs and fix issues

---

### Step 6: Create First Release

#### Method 1: Manual Tag Creation (Recommended for first release)

```bash
# Create v1.0.0 tag
git tag -a v1.0.0 -m "Release v1.0.0

Initial release with complete Docker stack for anonymous torrenting.

Features:
- Docker Compose setup with Gluetun + qBittorrent
- 60+ VPN providers support
- Triple-layer kill switch
- DNS leak protection
- Automated scripts and comprehensive documentation

🤖 Generated by GitHub Actions"

# Push tag
git push origin v1.0.0
```

**GitHub Actions will automatically create the release!**

#### Method 2: Auto Tag with GitHub Actions

1. Go to repository → **Actions** tab
2. Select **Auto Tag** workflow
3. Click **Run workflow**
4. Enter:
   - **Version**: `1.0.0`
   - **Release type**: `major`
5. Click **Run workflow**

**Workflow will automatically create tag and release!**

---

### Step 7: Advanced Features

#### 7.1 Setup Discussion Categories

**Discussions** tab → **Categories**:

Create categories:
- 📢 **Announcements**
- 💡 **Ideas**
- 🙏 **Q&A**
- 💬 **General**
- 🔧 **Troubleshooting** (custom)
- 🌐 **VPN Providers** (custom)

#### 7.2 Configure Issue Labels

**Issues** → **Labels**:

Add custom labels:
- `vpn`
- `qbittorrent`
- `docker`
- `documentation`
- `good first issue`
- `help wanted`

#### 7.3 Branch Protection (Optional)

**Settings** → **Branches** → **Branch protection rules**:

Protect `main` branch:
1. Click **Add rule**
2. **Branch name pattern**: `main`
3. Enable:
   - ✅ **Require pull request before merging**
   - ✅ **Require status checks to pass**
   - ✅ **Require conversation resolution**
4. Click **Create**

---

### Creating Subsequent Releases

#### Auto Version Bump (Recommended)

1. **Actions** → **Auto Tag**
2. Click **Run workflow**
3. Select release type:
   - **patch**: 1.0.0 → 1.0.1 (bug fixes)
   - **minor**: 1.0.0 → 1.1.0 (new features)
   - **major**: 1.0.0 → 2.0.0 (breaking changes)
4. Click **Run workflow**

#### Manual Tag Creation

```bash
# Create new version tag
git tag -a v1.1.0 -m "Release v1.1.0

New features:
- Added XYZ
- Improved ABC

Bug fixes:
- Fixed issue #123"

# Push tag
git push origin v1.1.0
```

---

### Troubleshooting

#### CI Workflow Fails

**Problem**: CI fails in Actions

**Solution**:
1. Go to **Actions** tab
2. Click failed workflow
3. Check logs
4. Fix errors and push

#### Release Not Created

**Problem**: Tag pushed but release not created

**Check**:
1. Tag format: `v1.0.0` (v prefix required)
2. Actions enabled
3. Workflow permissions

**Retry**:
```bash
# Delete tag
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0

# Recreate
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

#### Badges Show 404

**Problem**: Badges in README show 404

**Solution**:
1. Verify `yourusername` replaced with actual username
2. Ensure repository is Public
3. Wait for Actions to run at least once

---

### Useful Commands

#### Check Git Status
```bash
git status
git log --oneline --graph --all -10
git tag -l
```

#### Sync with Remote
```bash
git fetch --all --tags
git pull origin main
```

#### Manage Tags
```bash
# List all tags
git tag

# Show tag info
git show v1.0.0

# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin :refs/tags/v1.0.0
```

---

## 참고 자료

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [GitHub Flavored Markdown](https://github.github.com/gfm/)

---

**설정 완료!** 🎉 이제 프로젝트를 커뮤니티와 공유할 준비가 되었습니다!
