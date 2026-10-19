#!/bin/bash

# Check ig the user_add.txt file exists
# Check if all the paths exist.

# Admin specifies custom paths. If no custom paths are specified the defaults are used.
USERS_FILE="${1:-user_add.conf}"
KEYS_DIR="${2:-./ssh_secrets}"
OUT_FILE="${3:-./roles/users/defaults/main/user_add.yml}"
PUB_KEY_DIR="${4:-./roles/users/files/}"

# Create the directory that will store PRIVATE and PUBLIC keys.
# Move this to somewhere more secure.
mkdir -p "$KEYS_DIR" "$(dirname "$OUT_FILE")"
chmod 700 "$KEYS_DIR"

# Reads the users_add.conf file. Creates the ssh keys and puts them in the directory specified above.
# Outputs everything to a .yml file located in "./roles/users/defaults/main/user_add.yml"
# Copies the PUBLIC files to "./roles/users/files/"
{
  echo "---"
  echo "users_admins:"
while IFS= read -r user <&3 || [[ -n "$user" ]]; do
  user="${user//[$'\r ']/}"
  [[ -z "$user" || "$user" == \#* ]] && continue

  key="$KEYS_DIR/$user"
  if [[ ! -f "$key" ]]; then
    ssh-keygen -q -t ed25519 -N "" -C "$user" -f "$key.key" </dev/null >/dev/null
  fi

  printf '  - name: %s\n    ssh_key: %s.key.pub\n' "$user" "$user"
  cp  "$KEYS_DIR/$user.key.pub" "$PUB_KEY_DIR"
done 3< "$USERS_FILE"

} > "$OUT_FILE"

echo "Wrote $OUT_FILE"
