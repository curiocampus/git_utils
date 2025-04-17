#!/usr/bin/env bash
set -euo pipefail

# single_ssh_setup.sh: Automate SSH key generation, config append, agent start, and verification for one GitHub account.

KEY_TYPE="rsa"
KEY_BITS=4096

usage() {
  cat <<EOF
Usage: $0 --email <github_email> --alias <host_alias> [--key-dir <ssh_directory>]

Options:
  --email     Your GitHub email address
  --alias     Host alias for SSH config (e.g., github.com-personal)
  --key-dir   Directory for SSH keys and config (default: ~/.ssh)
EOF
  exit 1
}

# Default SSH directory
KEY_DIR="${KEY_DIR:-$HOME/.ssh}"

# Parse arguments
if (( $# == 0 )); then usage; fi
while [[ $# -gt 0 ]]; do
  case "$1" in
    --email)
      GITHUB_EMAIL="$2"; shift 2;;
    --alias)
      HOST_ALIAS="$2"; shift 2;;
    --key-dir)
      KEY_DIR="$2"; shift 2;;
    *)
      usage;;
  esac
done

# Validate required args
if [[ -z "${GITHUB_EMAIL:-}" || -z "${HOST_ALIAS:-}" ]]; then
  echo "Error: --email and --alias are required."
  usage
fi

# Prepare SSH directory
echo "==> Step 1: Preparing SSH directory at $KEY_DIR"
mkdir -p "$KEY_DIR" && chmod 700 "$KEY_DIR"
echo "[status] SSH directory ready"

# Derive key filename from alias (suffix after last hyphen)
SUFFIX="${HOST_ALIAS##*-}"
KEY_FILE="$KEY_DIR/id_rsa_$SUFFIX"

# Function: Generate SSH key if missing
generate_key() {
  local email="$1" file="$2"
  if [[ -f "$file" ]]; then
    echo "[skip] SSH key exists: $file"
  else
    echo "==> Step 2: Generating SSH key for $email"
    ssh-keygen -t "$KEY_TYPE" -b "$KEY_BITS" -C "$email" -f "$file"
    echo "[status] SSH key generated at $file"
  fi
}

# Function: Append host config if missing
append_config() {
  local alias="$1" file="$2" cfg="$KEY_DIR/config"
  touch "$cfg" && chmod 600 "$cfg"
  if grep -q "Host $alias" "$cfg"; then
    echo "[skip] Config for $alias already present"
  else
    echo "==> Step 3: Appending SSH config for $alias"
    cat >> "$cfg" <<EOF

Host $alias
  HostName github.com
  User git
  IdentityFile $file
EOF
    echo "[status] SSH config appended for $alias"
  fi
}

# Function: Start ssh-agent and add key
start_agent() {
  local file="$1"
  echo "==> Step 4: Starting ssh-agent and adding key"
  eval "$(ssh-agent -s)"
  ssh-add "$file"
  echo "[status] ssh-agent running and key added"
}

# Function: Verify SSH connection
verify_connection() {
  local alias="$1"
  echo "==> Step 5: Verifying SSH connection for $alias"
  if ssh -T "git@$alias" 2>&1 | grep -q "successfully authenticated"; then
    echo "[status] SSH verification successful for $alias"
  else
    echo "[warn] SSH verification failed for $alias"
  fi
}

# Main Execution
echo "Starting SSH setup for alias '$HOST_ALIAS'"
generate_key "$GITHUB_EMAIL" "$KEY_FILE"
append_config "$HOST_ALIAS" "$KEY_FILE"
start_agent "$KEY_FILE"
verify_connection "$HOST_ALIAS"

echo "✔ All steps completed for '$HOST_ALIAS'. You can now clone with:"
echo "    git clone git@$HOST_ALIAS:username/repo.git"
