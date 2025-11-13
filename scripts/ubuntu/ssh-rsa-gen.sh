#!/usr/bin/env bash
set -euo pipefail

# Uncomment for debug tracing:
# set -x

echo "=== RSA SSH Key Generator ==="

# Prompt for key name or path
read -rp "Enter a name or full path for your key (default: ~/.ssh/id_rsa): " KEY_PATH_INPUT
KEY_PATH_INPUT=${KEY_PATH_INPUT:-~/.ssh/id_rsa}

# Expand leading tilde (~) safely without eval
if [[ "$KEY_PATH_INPUT" == "~"* ]]; then
    # replace leading ~ or ~/ with $HOME
    KEY_PATH="${HOME}${KEY_PATH_INPUT:1}"
else
    KEY_PATH="$KEY_PATH_INPUT"
fi

# Normalize path (remove trailing slash if any)
KEY_PATH="${KEY_PATH%/}"

# Ensure parent directory exists
KEY_DIR="$(dirname "$KEY_PATH")"
if [[ ! -d "$KEY_DIR" ]]; then
    echo "Creating directory: $KEY_DIR"
    mkdir -p -- "$KEY_DIR"
    chmod 700 -- "$KEY_DIR"
fi

# Prompt for comment
read -rp "Enter a comment for your key (default: Ubuntu SSH RSA Key): " KEY_COMMENT
KEY_COMMENT=${KEY_COMMENT:-Ubuntu SSH RSA Key}

echo "Generating RSA key at: $KEY_PATH"
ssh-keygen -t rsa -b 4096 -C "$KEY_COMMENT" -f "$KEY_PATH"

# Start ssh-agent if not running (simple check)
if ! pgrep -u "$USER" ssh-agent >/dev/null 2>&1; then
    echo "Starting ssh-agent..."
    eval "$(ssh-agent -s)" >/dev/null
fi

# Add key to agent (ignore errors if agent refused)
if ssh-add "$KEY_PATH" >/dev/null 2>&1; then
    echo "Key added to ssh-agent."
else
    echo "Warning: ssh-add failed (agent may not be accessible)."
fi

# Prompt for remote details (optional)
read -rp "Copy public key to remote? (y/N): " COPY_ANS
COPY_ANS=${COPY_ANS:-N}
if [[ "$COPY_ANS" =~ ^[Yy]$ ]]; then
    read -rp "Enter remote username: " REMOTE_USER
    read -rp "Enter remote host (IP or domain): " REMOTE_HOST
    echo "Copying key to $REMOTE_USER@$REMOTE_HOST..."
    ssh-copy-id -i "${KEY_PATH}.pub" "$REMOTE_USER@$REMOTE_HOST"
fi

echo "✅ Done. Private key: $KEY_PATH"
echo "Public key: ${KEY_PATH}.pub"
echo "Connect with: ssh -i $KEY_PATH user@host"
