#!/usr/bin/env bash
# Week 3 networking lab: BREAK script.
#
# Applies ONE random, persistent network fault to THIS machine, then reboots it.
# Run it ONLY inside a throwaway lab VM. It refuses to run on a physical machine.
#
# Usage (run from the HOST, in the wiki folder):
#   multipass exec week3 -- sudo bash < labs/week3-network/week3-break.sh
#
# Mentor options:
#   multipass exec week3 -- sudo FAULT=2 bash < ...     # choose a fault (1-5) instead of random
#   multipass exec week3 -- sudo MODE=undo bash < ...   # remove every lab fault
#
# TODO-TEST: every fault below must be applied, diagnosed, and fixed once on a
# real multipass 24.04 VM before this lab is handed to an intern.

set -euo pipefail

LAB_TAG="lab-week3"
ANSWER="/root/.${LAB_TAG}-answer"
NETPLAN_FILE="/etc/netplan/99-${LAB_TAG}.yaml"
FAULT_COUNT=5
MODE="${MODE:-break}"

die() { echo "ERROR: $*" >&2; exit 1; }

# ---------- safety checks ----------
[[ $EUID -eq 0 ]] || die "run as root: sudo bash < week3-break.sh"
grep -q '^ID=ubuntu' /etc/os-release || die "this lab is for Ubuntu only"
systemd-detect-virt --quiet || die "this does not look like a VM. Refusing to break a real machine."
command -v netplan >/dev/null || die "netplan not found"

schedule_reboot() {
  # Reboot after this script returns, so `multipass exec` doesn't hang.
  # The reboot also proves the fault survives a restart.
  systemd-run --quiet --on-active=5 /usr/bin/systemctl reboot
}

# ---------- undo (mentor) ----------
if [[ $MODE == undo ]]; then
  rm -f "$NETPLAN_FILE"
  sed -i "/# ${LAB_TAG}\$/d" /etc/hosts
  systemctl enable --now systemd-resolved >/dev/null 2>&1 || true
  if command -v ufw >/dev/null; then
    ufw --force reset >/dev/null
    ufw --force disable >/dev/null || true
  fi
  rm -f "$ANSWER"
  echo "All lab faults removed. The VM reboots in 5 seconds."
  schedule_reboot
  exit 0
fi

[[ $MODE == break ]] || die "unknown MODE '$MODE' (use break or undo)"
[[ ! -e $ANSWER ]] || die "this VM is already broken. Fix it, or run with MODE=undo first."

# ---------- helpers ----------
netplan_id() {
  # The interface ID used in multipass's own netplan config (e.g. "default" or "ens3").
  # Our override must use the SAME ID so netplan merges it instead of adding a new interface.
  netplan get ethernets 2>/dev/null | awk '/^[^ #][^:]*:/ { sub(/:.*/, ""); print; exit }'
}

apt_hosts() {
  # Every mirror host apt uses on this machine (archive, security, or a regional mirror).
  grep -rhoE 'https?://[^/ ]+' /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null \
    | sed -E 's#^https?://##' | sort -u
}

write_netplan() {
  local body="$1"
  ( umask 077; printf '%s\n' "$body" > "$NETPLAN_FILE" )
  chmod 600 "$NETPLAN_FILE"
  netplan generate || { rm -f "$NETPLAN_FILE"; die "netplan rejected the lab config"; }
}

# Install what the faults need while the network still works.
command -v ufw  >/dev/null || apt-get install -y -qq ufw  >/dev/null
command -v curl >/dev/null || apt-get install -y -qq curl >/dev/null

FAULT="${FAULT:-$(( RANDOM % FAULT_COUNT + 1 ))}"
[[ $FAULT =~ ^[1-5]$ ]] || die "FAULT must be 1-${FAULT_COUNT}"

# ---------- faults ----------
case $FAULT in
  1)  # Dead DNS server, set persistently in netplan
      id="$(netplan_id)"; [[ -n $id ]] || die "could not find the netplan interface ID"
      write_netplan "network:
  version: 2
  ethernets:
    ${id}:
      dhcp4-overrides:
        use-dns: false
      nameservers:
        addresses: [192.0.2.53]"
      NAME="Dead DNS server"
      CAUSE="Netplan override $NETPLAN_FILE ignores the DHCP DNS server and sets 192.0.2.53 (unreachable)."
      FIX="Delete $NETPLAN_FILE (or remove its nameservers/use-dns lines), then: sudo netplan apply"
      ;;
  2)  # /etc/hosts sends apt's mirrors to an address that doesn't answer
      mapfile -t hosts < <(apt_hosts)
      [[ ${#hosts[@]} -gt 0 ]] || die "could not find apt mirror hosts"
      for h in "${hosts[@]}"; do
        printf '203.0.113.80\t%s # %s\n' "$h" "$LAB_TAG" >> /etc/hosts
      done
      NAME="Poisoned /etc/hosts"
      CAUSE="/etc/hosts maps the apt mirrors (${hosts[*]}) to 203.0.113.80 (unreachable). Other sites work."
      FIX="Remove those lines from /etc/hosts. No restart needed."
      ;;
  3)  # Local DNS resolver service stopped and disabled
      systemctl disable --now systemd-resolved >/dev/null 2>&1
      NAME="systemd-resolved disabled"
      CAUSE="systemd-resolved is stopped and disabled, so nothing answers on 127.0.0.53."
      FIX="sudo systemctl enable --now systemd-resolved"
      ;;
  4)  # No default route (DHCP routes ignored)
      id="$(netplan_id)"; [[ -n $id ]] || die "could not find the netplan interface ID"
      write_netplan "network:
  version: 2
  ethernets:
    ${id}:
      dhcp4-overrides:
        use-routes: false"
      NAME="No default route"
      CAUSE="Netplan override $NETPLAN_FILE ignores the routes DHCP provides, so there is no default route. Names still resolve (the DNS server is on the local subnet)."
      FIX="Delete $NETPLAN_FILE, then: sudo netplan apply"
      ;;
  5)  # Firewall blocks outbound web traffic
      ufw --force reset >/dev/null
      ufw default deny incoming  >/dev/null
      ufw default allow outgoing >/dev/null
      ufw allow 22/tcp           >/dev/null   # keep `multipass shell` working
      ufw deny out 80/tcp        >/dev/null
      ufw deny out 443/tcp       >/dev/null
      ufw --force enable         >/dev/null
      NAME="Firewall blocks outbound web"
      CAUSE="ufw denies OUTGOING tcp/80 and tcp/443. Ping and DNS still work."
      FIX="sudo ufw status numbered, then sudo ufw delete <n> for the two 'DENY OUT' rules"
      ;;
esac

# ---------- answer key (mentor) ----------
( umask 077; cat > "$ANSWER" <<EOF
Week 3 lab answer key. Fault #${FAULT}: ${NAME}
Applied:  $(date -Iseconds)
Cause:    ${CAUSE}
Fix:      ${FIX}
Diagnosis path and grading notes: labs/week3-network/MENTORS.md
EOF
)

echo "Lab fault applied. The VM reboots in 5 seconds."
echo
echo "  Wait ~30 seconds, then:  multipass shell <vm-name>"
echo "  Your task:               'sudo apt update' fails. Find out why and fix it."
echo "  When you think it works: run the check script (see labs/week3-network/README.md)"
schedule_reboot
