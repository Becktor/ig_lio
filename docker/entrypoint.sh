#!/bin/bash
set -e

# Default username (must match Dockerfile)
USERNAME="jobe"

# Ensure GID is provided via environment variables
if [ -z "$USER_GID" ]; then
    echo "WARNING: USER_GID not provided. Keeping default group."
else
    # Get current group information
    CURRENT_GID=$(id -g "$USERNAME")
    CURRENT_GROUP=$(id -gn "$USERNAME")

    echo "Current GID: $CURRENT_GID"
    echo "Desired GID: $USER_GID"

    if [ "$CURRENT_GID" != "$USER_GID" ]; then
        echo "Adding $USERNAME to existing group with GID $USER_GID..."

        # Get the existing group name for the provided GID
        TARGET_GROUP=$(getent group "$USER_GID" | cut -d: -f1)

        if [ -z "$TARGET_GROUP" ]; then
            echo "Group with GID $USER_GID does not exist. Skipping group addition."
        else
            sudo usermod -aG "$TARGET_GROUP" "$USERNAME" || echo "Failed to add user to group $TARGET_GROUP."
        fi
    else
        echo "$USERNAME is already in the desired group."
    fi
fi

# Fix ownership for the workspace and home directories
sudo chown -R "$USERNAME:$CURRENT_GROUP" "/home/$USERNAME" || echo "chown for /home/$USERNAME failed, but continuing."
sudo chown -R "$USERNAME:$CURRENT_GROUP" "/naisr2_ws" || echo "chown for /naisr2_ws failed, but continuing."

echo "Container ready."
# Execute the command as the existing user
exec "$@"
