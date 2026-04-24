#!/usr/bin/env bash
# =============================================================================
# Container entrypoint
#
# Responsibilities
#   1. Source /etc/icecc/icecc.conf (bind-mounted by the caller) and translate
#      its variables into iceccd command-line arguments.
#   2. Start iceccd in the background so it is available for the build.
#   3. Hand control to crops/poky's dumb-init → poky-entry.py chain, which
#      remaps the container user to match the calling host UID/GID.
#
# Config file is supplied at runtime, e.g.:
#   docker run ... -v /host/path/icecc.conf:/etc/icecc/icecc.conf:ro ...
#
# Minimal icecc.conf example:
#   ICECC_SCHEDULER_HOST="192.168.1.10"
#   ICECC_MAX_JOBS=8
#   ICECC_NETNAME="mybuild"
#   ICECC_NICE_LEVEL=5
# =============================================================================
set -euo pipefail

ICECC_CONF="/etc/icecc/icecc.conf"

# ---------------------------------------------------------------------------
# 1. Build the iceccd argument list
# ---------------------------------------------------------------------------
ICECCD_ARGS=(
    "-b" "/var/cache/icecc"
    "--log-file" "/var/log/icecc/iceccd.log"
)

if [ -f "${ICECC_CONF}" ]; then
    echo "[icecc] Sourcing config: ${ICECC_CONF}"
    source "${ICECC_CONF}"
else
    echo "[icecc] WARNING: ${ICECC_CONF} not found."
    echo "[icecc]   Mount your config with:"
    echo "[icecc]     -v /host/path/icecc.conf:${ICECC_CONF}:ro"
    echo "[icecc]   iceccd will start with defaults (no scheduler, local only)."
fi

# Scheduler host  →  -s <host>
if [ -n "${ICECC_SCHEDULER_HOST:-}" ]; then
    ICECCD_ARGS+=("-s" "${ICECC_SCHEDULER_HOST}")
    echo "[icecc] Scheduler: ${ICECC_SCHEDULER_HOST}"
fi

# Network name  →  -n <name>
if [ -n "${ICECC_NETNAME:-}" ]; then
    ICECCD_ARGS+=("-n" "${ICECC_NETNAME}")
fi

# Maximum parallel compile jobs accepted from the network  →  -m <n>
if [ -n "${ICECC_MAX_JOBS:-}" ]; then
    ICECCD_ARGS+=("-m" "${ICECC_MAX_JOBS}")
fi

# Nice level for compiler children  →  --nice <n>
if [ -n "${ICECC_NICE_LEVEL:-}" ]; then
    ICECCD_ARGS+=("--nice" "${ICECC_NICE_LEVEL}")
fi

# ---------------------------------------------------------------------------
# 2. Start iceccd in the background
# ---------------------------------------------------------------------------
echo "[icecc] Starting iceccd: /usr/sbin/iceccd ${ICECCD_ARGS[*]}"
/usr/sbin/iceccd "${ICECCD_ARGS[@]}" &

sleep 1

if kill -0 $! 2>/dev/null; then
    echo "[icecc] iceccd is running (PID $!)."
else
    echo "[icecc] WARNING: iceccd does not appear to be running."
    echo "[icecc]   Check /var/log/icecc/iceccd.log for details."
fi

# ---------------------------------------------------------------------------
# 3. Hand off to crops/poky
#    dumb-init becomes PID 1 and handles signal propagation.
#    poky-entry.py remaps the yoctouser UID/GID to match the host caller.
#    All arguments passed to `docker run <image> [args]` are forwarded here.
# ---------------------------------------------------------------------------
echo "[entrypoint] Starting crops/poky environment..."
exec /usr/bin/dumb-init -- /usr/bin/poky-entry.py "$@"
