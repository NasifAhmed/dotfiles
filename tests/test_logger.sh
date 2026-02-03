#!/usr/bin/env bash
# ==============================================================================
# Test: Logger Library
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source the logger
source "${DOTFILES_DIR}/lib/logger.sh"

# Test log file
TEST_LOG="/tmp/dotfiles_test_$$.log"
LOG_FILE="$TEST_LOG"

errors=0

# Test: log_init creates file
log_init
if [[ -f "$TEST_LOG" ]]; then
    echo "✓ log_init creates log file"
else
    echo "✗ log_init failed to create log file"
    ((errors++))
fi

# Test: log_info writes to file
log_info "Test info message"
if grep -q "INFO.*Test info message" "$TEST_LOG"; then
    echo "✓ log_info writes correctly"
else
    echo "✗ log_info failed"
    ((errors++))
fi

# Test: log_success writes to file
log_success "Test success"
if grep -q "SUCCESS.*Test success" "$TEST_LOG"; then
    echo "✓ log_success writes correctly"
else
    echo "✗ log_success failed"
    ((errors++))
fi

# Test: log_warning writes to file
log_warning "Test warning"
if grep -q "WARN.*Test warning" "$TEST_LOG"; then
    echo "✓ log_warning writes correctly"
else
    echo "✗ log_warning failed"
    ((errors++))
fi

# Test: log_error writes to file
log_error "Test error" 2>/dev/null
if grep -q "ERROR.*Test error" "$TEST_LOG"; then
    echo "✓ log_error writes correctly"
else
    echo "✗ log_error failed"
    ((errors++))
fi

# Test: timestamp format
if grep -qP '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}' "$TEST_LOG"; then
    echo "✓ Timestamp format is ISO 8601"
else
    echo "✗ Timestamp format incorrect"
    ((errors++))
fi

# Test: log_get_recent
recent=$(log_get_recent 3)
if [[ -n "$recent" ]]; then
    echo "✓ log_get_recent returns entries"
else
    echo "✗ log_get_recent failed"
    ((errors++))
fi

# Cleanup
rm -f "$TEST_LOG"

exit $errors
