#!/usr/bin/env bash
# Week 3 networking lab: CHECK script.
#
# Is the network healthy again, and was the cause fixed (not worked around)?
#
# Usage (run from the HOST, in the wiki folder):
#   multipass exec week3 -- sudo bash < labs/week3-network/week3-check.sh             # pass/fail only
#   multipass exec week3 -- sudo DETAILS=1 bash < labs/week3-network/week3-check.sh   # mentor: every check
#
# Exit code: 0 = healthy, 1 = not fixed yet, 2 = usage error.
#
# TODO-TEST: run against each of the 5 faults (broken -> FAIL) and after each fix (-> PASS).

set -uo pipefail

[[ $EUID -eq 0 ]] || { echo "run as root: sudo bash < week3-check.sh" >&2; exit 2; }
DETAILS="${DETAILS:-0}"

# First apt mirror host this machine uses (fallback: the main archive).
HOST="$(grep -rhoE 'https?://[^/ ]+' /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null \
        | sed -E 's#^https?://##' | sort -u | head -n1)"
HOST="${HOST:-archive.ubuntu.com}"

pass=0
fail=0
check() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then
    pass=$((pass + 1)); [[ $DETAILS == 1 ]] && echo "  PASS  $name"
  else
    fail=$((fail + 1)); [[ $DETAILS == 1 ]] && echo "  FAIL  $name"
  fi
  return 0
}

has_default_route()  { [[ -n "$(ip route show default)" ]]; }
uses_stub_resolver() { [[ "$(readlink -f /etc/resolv.conf)" == /run/systemd/resolve/stub-resolv.conf ]]; }
hosts_file_clean()   { ! grep -qwF "$HOST" /etc/hosts; }
resolves_for_real()  {
  local ip
  ip="$(getent ahostsv4 "$HOST" | awk 'NR==1 { print $1 }')"
  # Must resolve, and not to a documentation-only address (192.0.2/24, 198.51.100/24, 203.0.113/24).
  [[ -n $ip && ! $ip =~ ^(192\.0\.2\.|198\.51\.100\.|203\.0\.113\.) ]]
}
http_works()  { curl -sS -o /dev/null --max-time 10 "http://${HOST}/"; }
https_works() { curl -sS -o /dev/null --max-time 10 "https://ubuntu.com/"; }
apt_update_works() {
  local out
  out="$(timeout 120 apt-get update 2>&1)" || return 1
  # apt can exit 0 while still failing to fetch, so also scan its output. TODO-TEST
  ! grep -qE '^(E:|W: (Failed to fetch|Some index files failed))' <<< "$out"
}

[[ $DETAILS == 1 ]] && echo "Checking against apt mirror: $HOST"
check "default route exists"                        has_default_route
check "systemd-resolved is running"                 systemctl is-active --quiet systemd-resolved
check "/etc/resolv.conf uses the local resolver"    uses_stub_resolver
check "no /etc/hosts override for $HOST"            hosts_file_clean
check "$HOST resolves to a real address"            resolves_for_real
check "HTTP (port 80) to $HOST works"               http_works
check "HTTPS (port 443) works"                      https_works
check "apt update succeeds"                         apt_update_works

total=$((pass + fail))
echo
if [[ $fail -eq 0 ]]; then
  echo "PASS: all $total checks pass. The network is healthy. Exercise complete."
  exit 0
else
  echo "NOT FIXED YET: $fail of $total checks failing."
  [[ $DETAILS == 1 ]] || echo "Keep going with the runbook. Show a mentor once this script passes."
  exit 1
fi
