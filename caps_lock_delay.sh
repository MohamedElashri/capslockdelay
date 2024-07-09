#!/bin/bash

# Function to set Caps Lock delay
set_caps_lock_delay() {
    local delay=$1
    if hidutil property --set "{\"CapsLockDelayOverride\":$delay}"; then
        echo "CapsLock delay set to ${delay}ms successfully."
    else
        echo "Failed to set CapsLock delay. Please ensure you have the necessary permissions."
        exit 1
    fi
}

# AppleScript for user interaction
USER_CHOICE=$(osascript <<EOF
tell application "System Events"
    activate
    set user_input to display dialog "Enter the CapsLock delay in milliseconds (default is 0):" default answer "0" buttons {"Set Delay", "Disable", "Cancel"} default button 1
    return {button returned of user_input, text returned of user_input}
end tell
EOF
)

# Parsing the result from AppleScript
BUTTON_RETURNED=$(echo "$USER_CHOICE" | awk -F ', ' '{print $1}' | cut -d ':' -f2 | xargs)
TEXT_RETURNED=$(echo "$USER_CHOICE" | awk -F ', ' '{print $2}' | cut -d ':' -f2 | xargs)

# Handling user choice
case "$BUTTON_RETURNED" in
    "Set Delay")
        # Validate numeric input
        if [[ "$TEXT_RETURNED" =~ ^[0-9]+$ ]]; then
            set_caps_lock_delay "$TEXT_RETURNED"
        else
            echo "Invalid input. Please enter a numeric value."
            exit 1
        fi
        ;;
    "Disable")
        # Set delay to 0 to disable
        set_caps_lock_delay 0
        ;;
    "Cancel")
        echo "Operation cancelled by the user."
        exit 0
        ;;
    *)
        echo "Unexpected option: '$BUTTON_RETURNED', exiting."
        exit 1
        ;;
esac