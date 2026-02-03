#!/usr/bin/env bash
# ==============================================================================
# Test: Config Library
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Use temp config for testing
TEST_DIR="/tmp/dotfiles_test_config_$$"
mkdir -p "$TEST_DIR"
export DOTFILES_DIR="$TEST_DIR"

# Source the config library
source "$(dirname "$SCRIPT_DIR")/lib/config.sh"

errors=0

# Test: config_init creates file
config_init
if [[ -f "${TEST_DIR}/.dotfiles_config" ]]; then
    echo "✓ config_init creates config file"
else
    echo "✗ config_init failed"
    ((errors++))
fi

# Test: config_set and config_get
config_set "TEST_KEY" "test_value"
result=$(config_get "TEST_KEY")
if [[ "$result" == "test_value" ]]; then
    echo "✓ config_set/get works"
else
    echo "✗ config_set/get failed: got '$result'"
    ((errors++))
fi

# Test: config_get with default
result=$(config_get "NONEXISTENT" "default_val")
if [[ "$result" == "default_val" ]]; then
    echo "✓ config_get default works"
else
    echo "✗ config_get default failed: got '$result'"
    ((errors++))
fi

# Test: config_set_current_profile
config_set_current_profile "test_profile"
result=$(config_get_current_profile)
if [[ "$result" == "test_profile" ]]; then
    echo "✓ profile get/set works"
else
    echo "✗ profile get/set failed: got '$result'"
    ((errors++))
fi

# Test: config_list
list=$(config_list)
if [[ -n "$list" ]]; then
    echo "✓ config_list returns content"
else
    echo "✗ config_list failed"
    ((errors++))
fi

# Cleanup
rm -rf "$TEST_DIR"

exit $errors
