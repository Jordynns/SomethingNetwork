#!/usr/bin/env bash
set -e  # Exit if any command fails

echo "=== RSA SSH Key Generator ==="

# Prompt for key file path (default: ~/.ssh/id_rsa)
read -rp "Enter key path (default: ~/.ssh/id_rsa): " KEY_PATH
KEY_PATH=${KEY_PATH:-~/.ssh/id_rsa}

# Expand tilde (~) safely
KEY_PATH="${KEY_PATH/#\~/$HOME}"

# Make sure directory exists
mkdir -p "$(dirname "$KEY_PATH")"

# If file already exists, ask before overwriting
if [[ -f "$KEY_PATH" || -f "${KEY_PATH}.pub" ]]; then
    echo "⚠️  Key file already exists: $KEY_PATH"
    read -rp "Do you want to overwrite it? (y/N): " CONFIRM
    CONFIRM=${CONFIRM,,}  # convert to lowercase
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "yes" ]]; then
        echo "❌ Aborted. Existing key not overwritten."
        exit 1
    fi
    echo "Overwriting existing key..."
fi

# Prompt for custom comment
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
