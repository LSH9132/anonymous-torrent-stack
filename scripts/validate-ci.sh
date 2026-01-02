#!/bin/bash

# =================================================================
# CI 검증 스크립트 - 로컬에서 CI 체크를 미리 실행
# =================================================================
# 이 스크립트는 GitHub Actions에서 실행되는 검증을 로컬에서 수행합니다
# Usage: ./scripts/validate-ci.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

FAILED=0

# Check if running from project root
if [ ! -f "docker-compose.yml" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

print_header "CI Validation - Local Check"

# 1. Validate Docker Compose
print_header "1. Docker Compose Validation"
if docker compose config > /dev/null 2>&1; then
    print_success "Docker Compose configuration is valid"
else
    print_error "Docker Compose configuration is invalid"
    FAILED=1
fi

# 2. Validate .env.example
print_header "2. Environment Variables Check"
required_vars=(
    "VPN_PROVIDER"
    "VPN_TYPE"
    "QBITTORRENT_PORT"
    "GLUETUN_CONTROL_PORT"
)

for var in "${required_vars[@]}"; do
    if grep -q "^${var}=" .env.example; then
        print_success "Found required variable: $var"
    else
        print_error "Missing required variable: $var"
        FAILED=1
    fi
done

# 3. Check script permissions
print_header "3. Script Permissions Check"
for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            print_success "$script is executable"
        else
            print_warning "$script is not executable (will be set in CI)"
        fi
    fi
done

# 4. ShellCheck (if available)
print_header "4. ShellCheck (Optional)"
if command -v shellcheck &> /dev/null; then
    print_success "ShellCheck is available"

    SHELLCHECK_FAILED=0
    for script in scripts/*.sh; do
        if [ -f "$script" ]; then
            if shellcheck "$script" 2>/dev/null; then
                print_success "ShellCheck passed: $script"
            else
                print_warning "ShellCheck warnings in: $script"
                SHELLCHECK_FAILED=1
            fi
        fi
    done

    if [ $SHELLCHECK_FAILED -eq 0 ]; then
        print_success "All scripts passed ShellCheck"
    else
        print_warning "Some scripts have ShellCheck warnings (not critical)"
    fi
else
    print_warning "ShellCheck not installed (optional, will run in CI)"
    echo "  Install: brew install shellcheck (macOS) or apt install shellcheck (Linux)"
fi

# 5. YAML validation (if yamllint available)
print_header "5. YAML Validation (Optional)"
if command -v yamllint &> /dev/null; then
    print_success "yamllint is available"

    if yamllint -c .github/yamllint-config.yml docker-compose.yml .github/workflows/ 2>/dev/null; then
        print_success "YAML validation passed"
    else
        print_warning "YAML validation has warnings (not critical)"
    fi
else
    print_warning "yamllint not installed (optional, will run in CI)"
    echo "  Install: pip install yamllint"
fi

# 6. Check required documentation
print_header "6. Documentation Check"
required_docs=(
    "README.md"
    "README.ko.md"
    "CONTRIBUTING.md"
    "CHANGELOG.md"
    "LICENSE"
    "docs/setup-guide.md"
    "docs/troubleshooting.md"
    "docs/advanced-configuration.md"
)

for doc in "${required_docs[@]}"; do
    if [ -f "$doc" ]; then
        print_success "Found: $doc"
    else
        print_error "Missing: $doc"
        FAILED=1
    fi
done

# 7. Check for Korean translations
print_header "7. Translation Check"
if [ -f "README.md" ] && [ -f "README.ko.md" ]; then
    print_success "Korean translation exists"
else
    print_warning "Korean translation might be missing"
fi

# Summary
print_header "Summary"

if [ $FAILED -eq 0 ]; then
    print_success "All critical checks passed! ✨"
    echo ""
    echo "Your code is ready to push to GitHub."
    echo "CI checks should pass without issues."
    exit 0
else
    print_error "Some critical checks failed! ❌"
    echo ""
    echo "Please fix the issues above before pushing to GitHub."
    exit 1
fi
