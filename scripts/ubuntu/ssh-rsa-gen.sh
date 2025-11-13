#!/usr/bin/env bash
set -e  # exit if any command fails

echo "=== RSA SSH Key Generator ==="

# Prompt for custom key file path (default: ~/.ssh/id_rsa)
read -rp "Enter key path (default: ~/.ssh/id_rsa): " KEY_PATH
KEY_PATH=${KEY_PATH:-~/.ssh/id_rsa}

# Expand ~ properly
KEY_PATH="${KEY_PATH/#\~/$HOME}"

# Make sure directory exists
mkdir -p "$(dirname "$KEY_PATH")"

# Prompt for a custom comment
read -rp "Enter a comment for your key (default: Ubuntu SSH RSA Key): " KEY_COMMENT
KEY_COMMENT=${KEY_COMMENT:-Ubuntu SSH RSA Key}

# Generate the RSA key pair
echo "Generating 4096-bit RSA key at: $KEY_PATH"
ssh-keygen -t rsa -b 4096 -C "$KEY_COMMENT" -f "$KEY_PATH"

echo
echo "✅ RSA key generation complete!"
echo "Private key: $KEY_PATH"
echo "Public key:  ${KEY_PATH}.pub"
echo "Comment:     $KEY_COMMENT"
