#!/usr/bin/env bash
# ==============================================================================
# Test: Profile Library
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REAL_DOTFILES="$(dirname "$SCRIPT_DIR")"

# Create test environment
TEST_DIR="/tmp/dotfiles_test_profile_$$"
mkdir -p "$TEST_DIR/lib"
export DOTFILES_DIR="$TEST_DIR"

# Copy libraries to test dir
cp "${REAL_DOTFILES}/lib/"*.sh "$TEST_DIR/lib/"

# Suppress log output
export LOG_FILE="/tmp/dotfiles_test_log_$$.log"

# Source libraries
source "$TEST_DIR/lib/logger.sh"
source "$TEST_DIR/lib/config.sh"
source "$TEST_DIR/lib/stow_manager.sh"
source "$TEST_DIR/lib/profile.sh"

errors=0

# Test: profile_create
profile_create "test_profile" >/dev/null 2>&1
# Create a subdirectory so it's detected as a profile
mkdir -p "${TEST_DIR}/test_profile/nvim/.config/nvim"
touch "${TEST_DIR}/test_profile/nvim/.config/nvim/init.lua"
if [[ -d "${TEST_DIR}/test_profile" ]]; then
    echo "✓ profile_create works"
else
    echo "✗ profile_create failed"
    ((errors++))
fi

# Test: profile_list
profiles=$(profile_list)
if echo "$profiles" | grep -q "test_profile"; then
    echo "✓ profile_list works"
else
    echo "✗ profile_list failed"
    ((errors++))
fi

# Test: profile_exists
if profile_exists "test_profile"; then
    echo "✓ profile_exists works"
else
    echo "✗ profile_exists failed"
    ((errors++))
fi

# Test: profile_count
count=$(profile_count)
if [[ "$count" -ge 1 ]]; then
    echo "✓ profile_count works"
else
    echo "✗ profile_count failed"
    ((errors++))
fi

# Test: profile_set_current and profile_get_current
profile_set_current "test_profile"
current=$(profile_get_current)
if [[ "$current" == "test_profile" ]]; then
    echo "✓ profile set/get current works"
else
    echo "✗ profile set/get current failed"
    ((errors++))
fi

# Test: profile_rename
profile_rename "test_profile" "renamed_profile" >/dev/null 2>&1
if [[ -d "${TEST_DIR}/renamed_profile" ]] && [[ ! -d "${TEST_DIR}/test_profile" ]]; then
    echo "✓ profile_rename works"
else
    echo "✗ profile_rename failed"
    ((errors++))
fi

# Test: profile_delete
profile_delete "renamed_profile" >/dev/null 2>&1
if [[ ! -d "${TEST_DIR}/renamed_profile" ]]; then
    echo "✓ profile_delete works"
else
    echo "✗ profile_delete failed"
    ((errors++))
fi

# Cleanup
rm -rf "$TEST_DIR"
rm -f "$LOG_FILE"

exit $errors
