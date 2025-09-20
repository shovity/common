#!/bin/bash

# Script to manage Squid proxy users
# Usage: ./manage_users.sh add <username> <password>
#        ./manage_users.sh remove <username>
#        ./manage_users.sh list

PASSWD_FILE="./passwd"

# Create password file if it doesn't exist
if [ ! -f "$PASSWD_FILE" ]; then
    echo "Creating new password file: $PASSWD_FILE"
    touch "$PASSWD_FILE"
    chmod 600 "$PASSWD_FILE"  # Secure permissions
fi

case "$1" in
    "add")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 add <username> <password>"
            exit 1
        fi
        echo "Adding user: $2"
        # Check if htpasswd is available
        if command -v htpasswd &> /dev/null; then
            htpasswd -b "$PASSWD_FILE" "$2" "$3"
        else
            # Fallback: create basic auth entry (not recommended for production)
            echo "Warning: htpasswd not found. Using basic encoding (not secure for production)"
            echo "$2:$(echo -n "$3" | base64)" >> "$PASSWD_FILE"
        fi
        echo "User $2 added successfully"
        ;;
    "remove")
        if [ -z "$2" ]; then
            echo "Usage: $0 remove <username>"
            exit 1
        fi
        echo "Removing user: $2"
        sed -i "/^$2:/d" "$PASSWD_FILE"
        echo "User $2 removed successfully"
        ;;
    "list")
        echo "Current users:"
        if [ -f "$PASSWD_FILE" ]; then
            cut -d: -f1 "$PASSWD_FILE" | grep -v "^#"
        else
            echo "No users found"
        fi
        ;;
    *)
        echo "Usage: $0 {add|remove|list}"
        echo "  add <username> <password>  - Add a new user"
        echo "  remove <username>          - Remove a user"
        echo "  list                       - List all users"
        exit 1
        ;;
esac
