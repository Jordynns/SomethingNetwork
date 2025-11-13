#!/bin/bash
set -e  # Exit on error

echo "=== RSA SSH Key Generator ==="

# Prompt for key name or path
read -rp "Enter a name or full path for your key (default: ~/.ssh/id_rsa): " KEY_PATH
KEY_PATH=${KEY_PATH:-~/.ssh/id_rsa}

# Expand tilde (~)
KEY_PATH=$(eval echo "$KEY_PATH")

# Prompt for comment
read -rp "Enter a comment for your key (default: Ubuntu SSH RSA Key): " KEY_COMMENT
KEY_COMMENT=${KEY_COMMENT:-Ubuntu SSH RSA Key}

# Generate the key pair
echo "Generating RSA key at: $KEY_PATH"
ssh-keygen -t rsa -b 4096 -C "$KEY_COMMENT" -f "$KEY_PATH"

# Start ssh-agent if not running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    echo "Starting ssh-agent..."
    eval "$(ssh-agent -s)"
fi

# Add key to agent
ssh-add "$KEY_PATH"

# Prompt for remote details
read -rp "Enter remote username: " REMOTE_USER
read -rp "Enter remote host (IP or domain): " REMOTE_HOST

# Copy the public key to the remote server
echo "Copying key to $REMOTE_USER@$REMOTE_HOST..."
ssh-copy-id -i "${KEY_PATH}.pub" "$REMOTE_USER@$REMOTE_HOST"

echo "✅ All done!"
echo "You can now connect using:"
echo "ssh -i $KEY_PATH $REMOTE_USER@$REMOTE_HOST"
