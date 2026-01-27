#!/usr/bin/env bash

set -e

echo "=== RSA SSH Key Generator ==="

read -rp "Enter key path (default: ~/.ssh/id_rsa): " KEY_PATH
KEY_PATH=${KEY_PATH:-~/.ssh/id_rsa}
KEY_PATH="${KEY_PATH/#\~/$HOME}"

mkdir -p "$(dirname "$KEY_PATH")"

if [[ -f "$KEY_PATH" || -f "${KEY_PATH}.pub" ]]; then
    echo "⚠️  Key file already exists: $KEY_PATH"
    read -rp "Do you want to overwrite it? (y/N): " CONFIRM
    CONFIRM=${CONFIRM,,}
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "yes" ]]; then
        echo "❌ Aborted. Existing key not overwritten."
        exit 1
    fi
    echo "Overwriting existing key..."
fi

read -rp "Enter a comment for your key (default: Ubuntu SSH RSA Key): " KEY_COMMENT
KEY_COMMENT=${KEY_COMMENT:-Ubuntu SSH RSA Key}

echo "Generating 4096-bit RSA key at: $KEY_PATH"
ssh-keygen -t rsa -b 4096 -C "$KEY_COMMENT" -f "$KEY_PATH" -N ""

echo
echo "✅ RSA key generation complete!"
echo "Private key: $KEY_PATH"
echo "Public key:  ${KEY_PATH}.pub"
echo "Comment:     $KEY_COMMENT"

echo
read -rp "Do you want to install this key on a remote server now? (y/N): " INSTALL_KEY
INSTALL_KEY=${INSTALL_KEY,,}

if [[ "$INSTALL_KEY" == "y" || "$INSTALL_KEY" == "yes" ]]; then
    read -rp "Enter remote user (e.g. ubuntu): " REMOTE_USER
    read -rp "Enter server address (IP or hostname): " REMOTE_HOST

    echo "📤 Copying public key to $REMOTE_USER@$REMOTE_HOST"
    ssh-copy-id -i "${KEY_PATH}.pub" "$REMOTE_USER@$REMOTE_HOST"

    echo "✅ Public key installed on remote server"
else
    echo "ℹ️  Skipping key installation"
fi

echo "============================="

rm -- "$0"
