#!/usr/bin/env bash
# config.local.fish must be sourced exactly once on Linux and macOS (#15).
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
check() {
  local name=$1 attr=$2 init count
  init=$(nix eval --raw ".#$attr.programs.fish.interactiveShellInit")
  count=$(grep -c 'source ~/.config/fish/config.local.fish' <<<"$init" || true)
  if [ "$count" -eq 1 ]; then
    echo "ok   $name: sourced once"
  else
    echo "FAIL $name: sourced $count times"
    fail=1
  fi
}

check linux homeConfigurations.mince.config
check mac darwinConfigurations.mince-mac.config.home-manager.users.mince
exit "$fail"
