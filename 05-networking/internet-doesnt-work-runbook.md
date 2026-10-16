---
title: The "internet doesn't work" runbook
level: L2                 # steps 1–6 are L1; "Go deeper" is L2
type: how-to
distros:
  ubuntu: ["24.04"]
requires: [iproute2, iputils-ping, iputils-tracepath, systemd-resolved, curl, netcat-openbsd]
risk: changes-system      # diagnosis is read-only; the fixes change the system
last_tested: TODO-TEST
tags: [networking, troubleshooting, runbook, dns]
---

<!-- TODO-TEST: before publishing, `grep -n TODO-TEST` this file and resolve every hit:
  1. Run every command on 24.04 Desktop (NetworkManager) AND in multipass (systemd-networkd)
  2. Replace every sample output with REAL output, including the broken cases:
     break each step on purpose with labs/week3-network (FAULT=1..5) and capture what you see
  3. Confirm netcat-openbsd and iputils-tracepath are installed by default on Desktop and Server
  4. Confirm the Kali note at the bottom (no systemd-resolved by default)
  5. Set last_tested
-->

# The "internet doesn't work" runbook

## TL;DR

Check the six steps **in order** and stop at the first one that fails. That one is your problem.

![Opening a website: link → IP → gateway → DNS → route → port](../_assets/network-request-journey.svg)

The whole check in six commands:

```bash
ip -br link                       # 1. Link: is the interface UP?
ip -br -4 addr                    # 2. IP: do I have a real address?
ip route show default             # 3. Gateway: do I have a default route? (note the "via" address)
ping -c3 1.1.1.1                  # 5. Route out: can I reach the internet by IP?
resolvectl query example.com      # 4. DNS: can I turn a name into an address?
curl -sSI https://example.com     # 6. Port: can I actually connect to a website?
```

Yes, step 5 runs before step 4. That's on purpose: if you can't reach `1.1.1.1` by IP, DNS can't work either, so test the road before the phone book. See [step 4](#step-4--dns) for why.

> [!TIP]
> Not sure what an IP, gateway, or DNS server is? Read [networking concepts](concepts-no-commands.md) first. Ten minutes there saves an hour here.

## When you need this

"The internet is down," a page won't load, `sudo apt update` fails, Slack connects but the browser doesn't. Any time something network-shaped is broken and you don't know why.

**Don't** start by rebooting, reinstalling, or toggling Wi-Fi at random. Those sometimes work, but you learn nothing, and when they don't work you've lost the evidence.

## Commands

> Tested on: **Ubuntu 24.04** Desktop and Server TODO-TEST

> [!NOTE]
> **Which network manager do you have?** Ubuntu **Desktop** uses NetworkManager (`nmcli`,
> the Wi-Fi icon). Ubuntu **Server**, cloud images, and Multipass VMs use
> systemd-networkd, configured through netplan. Diagnosis (steps 1–6) is identical on
> both; only some *fixes* differ, and each fix says which one it's for.

### Step 1 — Link

**Question:** is my machine physically connected to *anything*?

```bash
ip -br link
```

Look at your real interface (not `lo`): `en…`/`eth…` is a cable, `wl…` is Wi-Fi.

- `UP` with `LOWER_UP` in the flags → ✅ link is fine, go to step 2.
- `DOWN`, or `NO-CARRIER` → ❌ no link.

**Fix:**

- Cable: replug it, try another cable or port. `NO-CARRIER` means the other end isn't answering.
- Wi-Fi (Desktop):

  ```bash
  nmcli radio wifi           # "disabled"? → nmcli radio wifi on
  rfkill list                # "Soft blocked: yes" → airplane mode; "Hard blocked: yes" → a physical switch/Fn key
  nmcli device wifi list     # can you see your network at all?
  ```

### Step 2 — IP address

**Question:** did the router give me an address?

```bash
ip -br -4 addr
```

- A normal private address such as `192.168.1.23/24` or `10.x.x.x` → ✅ go to step 3.
- **No address** on your interface → ❌ DHCP didn't run or didn't answer.
- **`169.254.x.x`** → ❌ DHCP **failed** and your machine invented an address. The problem is between you and the router.

**Fix:** ask for an address again.

```bash
# Desktop (NetworkManager): find the connection name, then restart it
nmcli connection show --active
nmcli connection up "<connection name>"
```

```bash
# Server / Multipass (systemd-networkd)
sudo networkctl reconfigure <interface>
```

> [!WARNING]
> Over SSH, renewing your address can disconnect you. Only do it on a machine you can reach with a keyboard and screen.

Still `169.254.x.x`? Restart the router, or check whether other devices on the same network get an address. If they don't either, it's not your machine.

### Step 3 — Gateway

**Question:** do I know where to send traffic that leaves my network, and is that place reachable?

```bash
ip route show default
```

- `default via 192.168.1.1 dev wlp2s0 …` → you have a default route. The `via` address is your gateway (usually your router). Now ping it:

  ```bash
  ping -c3 192.168.1.1        # use YOUR "via" address
  ```

  Replies → ✅ go to step 5 (yes, 5; see the TL;DR).
  `Destination Host Unreachable` → ❌ the router isn't answering on your local network. Restart it, or check you're on the right Wi-Fi.

- **No output at all** → ❌ **no default route.** Your machine has an address but no idea how to leave the local network. Typical symptom: `ping 1.1.1.1` says `Network is unreachable` immediately.

**Fix for a missing default route:** find out *why* it's missing before adding one by hand.

```bash
# Server / Multipass: is something in netplan telling DHCP routes to be ignored?
ls /etc/netplan/
sudo netplan get                       # look for "use-routes: false" or a "routes:" section
```

```bash
# Desktop: is the connection set to ignore automatic routes?
nmcli connection show "<connection name>" | grep -i ipv4.ignore-auto-routes
```

Remove the setting that causes it, then reapply (`sudo netplan apply` / `nmcli connection up "<name>"`).

> [!CAUTION]
> `sudo ip route add default via <gateway>` makes it work **until the next reboot**, then it's broken again. Fine for a quick test; never the real fix.

### Step 5 — Route out

**Question:** does traffic make it past my router to the internet?

```bash
ping -c3 1.1.1.1
```

- Replies → ✅ the network works by IP. Go to step 4.
- Timeouts, while the gateway (step 3) answers → ❌ the problem is **beyond your machine**: the router, the ISP, or a VPN.

See where it stops:

```bash
tracepath -n 1.1.1.1
```

- Stops at hop 1 (your router) → the router has no internet. Check other devices; check the router's own status page.
- Your traffic goes through `tun0`, `wg0`, or `ppp0` → a VPN is routing everything. Disconnect it and test again.

```bash
ip route                          # any routes via tun0/wg0? That's the VPN
```

### Step 4 — DNS

**Question:** can my machine turn names into addresses?

This step comes after step 5 because DNS needs the network: you first prove that `ping 1.1.1.1` works, then test names. If `ping 1.1.1.1` works and `ping example.com` doesn't, it's DNS, every time.

**4a. Ask the resolver directly:**

```bash
resolvectl query example.com
```

- An address comes back → the DNS *service* works. Do 4c anyway; it catches the sneaky case.
- `resolve call failed: …` or a timeout → ❌ DNS is broken. Continue with 4b.

**4b. Is the local resolver running, and which DNS server is it using?**

```bash
systemctl status systemd-resolved     # must be "active (running)"
resolvectl status                     # look at "Current DNS Server" for your interface
```

| What you see | Cause | Fix |
|---|---|---|
| `inactive (dead)` or `disabled` | The local resolver is off | `sudo systemctl enable --now systemd-resolved` |
| A DNS server that doesn't answer, or one you don't recognise | Wrong DNS server configured | Find where it comes from (below) |
| No DNS server at all on your interface | DHCP DNS is being ignored | Find where (below) |

Where can a DNS server setting come from?

```bash
ls /etc/netplan/ && sudo netplan get                          # Server/Multipass: "nameservers:" or "use-dns: false"
nmcli connection show "<connection name>" | grep -i dns       # Desktop: ipv4.dns / ipv4.ignore-auto-dns
```

Remove the wrong setting, then reapply (`sudo netplan apply` / `nmcli connection up "<name>"`).

> [!NOTE]
> On Ubuntu, `/etc/resolv.conf` says `nameserver 127.0.0.53`. That's **normal**: it's the
> local resolver (systemd-resolved), which forwards your questions to the real DNS
> server. Don't "fix" it by writing a different server into that file; the next
> restart overwrites it and you've hidden the real problem.

**4c. Do all tools agree on the address?**

```bash
getent hosts example.com              # what your apps actually get
resolvectl query example.com          # what DNS says
```

They should show the same address. If `getent` shows something **different** (often a strange address like `203.0.113.x`), something answered *before* DNS did, and that something is almost always `/etc/hosts`:

```bash
grep -v '^#' /etc/hosts
```

Delete any line that maps the broken site to an address. The change takes effect immediately.

> [!WARNING]
> Edit `/etc/hosts` with `sudoedit /etc/hosts`. A typo can break `localhost`; keep the `127.0.0.1 localhost` and `::1` lines.

### Step 6 — Port

**Question:** the network works and names resolve, but can I connect to the *service*?

```bash
curl -sSI https://example.com
```

- `HTTP/2 200` (or any `HTTP/…` line) → ✅ **everything works.** If one specific app still fails, it's that app (its proxy settings, its login, its server), not your network.
- Hangs, then `Connection timed out` → ❌ something is **silently dropping** the traffic, usually a firewall.
- `Connection refused` immediately → ❌ you reached the machine, but nothing is listening on that port. It's the server's problem, not yours.

Test the port directly, without HTTP in the way:

```bash
nc -zv -w5 example.com 443            # HTTPS
nc -zv -w5 example.com 80             # HTTP
```

If ping works but these time out, check **your own** firewall first:

```bash
sudo ufw status verbose
```

Look for `DENY OUT` lines on 80 or 443. Remove them by number:

```bash
sudo ufw status numbered
sudo ufw delete <number>              # numbers shift after each delete: re-run "status numbered" between deletes
```

> [!WARNING]
> `sudo ufw disable` also "fixes" it, by turning off **all** your firewall rules. Delete the one wrong rule instead.

Still blocked, and `ufw` is clean? Check for a proxy setting, then suspect the network itself (an office or hotel firewall):

```bash
env | grep -i proxy
```

## What the output means

TODO-TEST: replace every sample below with real output from a 24.04 machine, including the broken versions (use `labs/week3-network` with `FAULT=1..5`).

**`ip -br link`**

```
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
wlp2s0           UP             3c:22:fb:12:34:56 <BROADCAST,MULTICAST,UP,LOWER_UP>
```

- Column 2 is the state: `UP` is good, `DOWN` is off.
- `LOWER_UP` = the cable or Wi-Fi link is physically up. `UP` without `LOWER_UP` = switched on but not connected.

**`ip -br -4 addr`**

```
lo               UNKNOWN        127.0.0.1/8
wlp2s0           UP             192.168.1.23/24
```

- `192.168.1.23` = your address. `/24` = your subnet size (see [concepts](concepts-no-commands.md#subnet-your-street)).
- `169.254.x.x` here = DHCP failed (step 2).

**`ip route show default`**

```
default via 192.168.1.1 dev wlp2s0 proto dhcp src 192.168.1.23 metric 600
```

- `via 192.168.1.1` = your gateway. `dev wlp2s0` = the interface it goes out of.
- `proto dhcp` = the router gave you this route. Missing entirely = step 3 failure.

**`resolvectl status`** (trimmed)

```
Link 3 (wlp2s0)
    Current Scopes: DNS
Current DNS Server: 192.168.1.1
       DNS Servers: 192.168.1.1
```

- `Current DNS Server` = who answers your name lookups. Usually your router, or something like `1.1.1.1`.

**`curl -sSI https://example.com`**

```
HTTP/2 200
content-type: text/html
```

- Any `HTTP/` line means the whole chain, steps 1–6, works.

## If it doesn't work

- **Every step passes, but one website still fails** → it's that website, or `/etc/hosts` (step 4c). Try `curl -sSI` on a different site to be sure.
- **Every step passes, but one app fails** → that app's own proxy or network settings, or its server is down. Not your network.
- **It works, then breaks again after a reboot** → you fixed the symptom with a temporary command (`ip route add`, editing `/etc/resolv.conf`). Find the setting that causes it (netplan, NetworkManager, ufw) and fix that.
- **Works on Wi-Fi, not on cable (or the reverse)** → each interface has its own settings. Run steps 1–4 for the interface that fails.
- **Works for others on the same network, not for you** → it's your machine. Steps 2–4 and 6 are the likely suspects.
- **Fails for everyone on the network** → the router or the ISP. Step 5 confirms it; there's nothing to fix on your laptop.

## Go deeper (L2 / L3)

### Why the six steps aren't strictly in order

The journey diagram is simplified. In reality the DNS lookup in step 4 *itself* travels through steps 1, 2, 3, and 5 to reach the DNS server. That's why a broken route (step 3/5) also breaks DNS, and why this runbook proves `ping 1.1.1.1` works before blaming DNS. One exception: if your DNS server is on your *local* network (often the router), names can still resolve with **no default route**. "DNS works but nothing else does" points straight at step 3.

### Error messages are clues

| Message | Meaning | Step |
|---|---|---|
| `Network is unreachable` | No route at all for that address | 3 |
| `Destination Host Unreachable` | Route exists, but the next hop doesn't answer on the local network | 3 |
| `Temporary failure in name resolution` | DNS lookup failed | 4 |
| `Connection timed out` | Packets silently dropped, usually a firewall | 6 |
| `Connection refused` | Reached the host, nothing listening on that port | 6 (their side) |

### `dig` and `nslookup` lie about `/etc/hosts`

`dig` and `nslookup` query a DNS server directly and **skip `/etc/hosts`**, so they can say everything is fine while your browser goes to the wrong address. `getent hosts <name>` uses the same lookup path your applications do (`/etc/nsswitch.conf`: files first, then DNS). When debugging "why does *my app* get this address," use `getent`. (`dig` is in the `bind9-dnsutils` package, which isn't installed by default.) TODO-TEST

### IPv6

Everything above uses IPv4 (`-4`, `1.1.1.1`). If IPv4 works and some sites still fail, check IPv6 the same way: `ip -br -6 addr`, `ip -6 route show default`, `ping -6 -c3 2606:4700:4700::1111`. A broken IPv6 setup can make *some* sites slow or fail while others work.

> [!NOTE]
> **Kali Linux** follows the same six steps with the same `ip`, `ping`, `curl`, and `nc` commands. Step 4 differs: Kali doesn't use systemd-resolved by default, so `/etc/resolv.conf` lists the real DNS server directly and `resolvectl` may not be available. TODO-TEST. See the Kali track.

## Related

- [Networking concepts, no commands](concepts-no-commands.md): what each step *is*
- [Week 3 lab: the internet doesn't work](../labs/week3-network/README.md): practise this runbook on a deliberately broken VM
- [What's my IP / am I connected](whats-my-ip-am-i-connected.md)
- [DNS on Ubuntu](dns-on-ubuntu.md): systemd-resolved in depth
- [Connections and ports](connections-and-ports.md)
- [Firewall (ufw)](firewall-ufw.md)
