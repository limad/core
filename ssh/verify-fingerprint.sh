#!/usr/bin/env bash
# Verifies the live SSH host key for 192.168.1.80 matches the pinned fingerprint.
# Exits 0 on match, non-zero otherwise.
set -euo pipefail

HOST="192.168.1.80"
EXPECTED="SHA256:qhFn24/t9gmMC8FFuddC/xkf5hy+GyPcLbwd1U3Hd/M"

actual="$(ssh-keyscan -T 5 "$HOST" 2>/dev/null \
    | ssh-keygen -lf - \
    | awk '{print $2}' \
    | sort -u)"

if [ -z "$actual" ]; then
    echo "error: could not retrieve host key from $HOST" >&2
    exit 2
fi

if grep -qxF "$EXPECTED" <<<"$actual"; then
    echo "ok: $HOST presents expected key $EXPECTED"
    exit 0
fi

echo "MISMATCH: $HOST presented:" >&2
echo "$actual" >&2
echo "expected: $EXPECTED" >&2
exit 1
