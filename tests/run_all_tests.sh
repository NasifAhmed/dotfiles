#!/usr/bin/env bash
# ==============================================================================
# Test Runner - Runs all tests
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

passed=0
failed=0
total=0

run_test() {
    local test_file="$1"
    local test_name
    test_name=$(basename "$test_file" .sh)
    
    echo -e "${BLUE}▶${RESET} Running: $test_name"
    ((total++))
    
    if bash "$test_file"; then
        echo -e "${GREEN}✓${RESET} $test_name passed"
        ((passed++))
    else
        echo -e "${RED}✗${RESET} $test_name failed"
        ((failed++))
    fi
    echo ""
}

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║        Dotfiles Manager Test Suite            ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

# Run all test files
for test_file in "$SCRIPT_DIR"/test_*.sh; do
    if [[ -f "$test_file" ]]; then
        run_test "$test_file"
    fi
done

# Summary
echo "═══════════════════════════════════════════════"
echo ""
if [[ $failed -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${RESET} ($passed/$total)"
else
    echo -e "${RED}Some tests failed!${RESET}"
    echo -e "  Passed: ${GREEN}$passed${RESET}"
    echo -e "  Failed: ${RED}$failed${RESET}"
    echo -e "  Total:  $total"
fi
echo ""

exit $failed
