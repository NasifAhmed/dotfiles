#!/bin/bash
# Wrapper to ensure we always run the latest version
REPO_ROOT="$(dirname "$(readlink -f "$0")")"
"$REPO_ROOT/bootstrap.sh"
exec "$HOME/.local/bin/dotman" "$@"
