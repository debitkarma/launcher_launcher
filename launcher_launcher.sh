#!/bin/bash

# A self-installing script to launch... launchers!
# Version: 0.1.0
#
# Okay, so it "installs" standalone executables and creates an entry for
# launchers to find them.
#
# If run without arguments, it will install itself to the user's local bin and
# create a desktop entry for application menus.
#
# If run with arguments, it will execute the main script logic. You should be
# able to create a shortcut to this somewhere and then drag and drop files onto
# it to install them.

# --- Configuration ---
readonly SCRIPT_VERSION="0.1.0"
readonly SCRIPT_NAME=$(basename "$0")
readonly INSTALL_DIR="$HOME/.local/bin"
readonly APPS_DIR="$HOME/.local/share/applications"

readonly INSTALL_PATH="$INSTALL_DIR/$SCRIPT_NAME"
# Use the script name without the .sh extension for the desktop file name
readonly DESKTOP_FILE_NAME="${SCRIPT_NAME%.sh}.desktop"
readonly DESKTOP_FILE_PATH="$APPS_DIR/$DESKTOP_FILE_NAME"

# --- Self-Installation Logic ---
# If the script is run without any arguments, perform the installation.
if [ "$#" -eq 0 ]; then
    echo "No arguments detected. Proceeding with installation..."

    # 1. Ensure the target directories exist.
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$APPS_DIR"
    echo "-> Ensured directories exist: $INSTALL_DIR and $APPS_DIR"

    # 2. Copy this script to the installation path and make it executable.
    cp "$0" "$INSTALL_PATH"
    chmod +x "$INSTALL_PATH"
    echo "-> Script installed to $INSTALL_PATH"

    # 3. Create the .desktop file to make it appear in application launchers.
    echo "-> Creating desktop entry at $DESKTOP_FILE_PATH"
    cat << EOF > "$DESKTOP_FILE_PATH"
[Desktop Entry]
Version=$SCRIPT_VERSION
Type=Application
Name=Launcher Launcher
Comment=Installs other standalone programs as desktop applications for standard launchers to find
Exec=$INSTALL_PATH %F
Icon=utilities-terminal
Terminal=false
Categories=Utility;
EOF

    echo
    echo "--- Installation Complete ---"
    echo "-> You can now find 'Launcher Launcher' in your application menu."
    echo "-> You may safely delete the original script you ran: $(realpath "$0")"

    # Ask to create a desktop shortcut for drag-and-drop functionality
    echo
    read -p "Create a shortcut on your Desktop for easy drag-and-drop? (y/N) " -n 1 -r
    echo # Move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -d "$HOME/Desktop" ]; then
            # Use a more descriptive name for the shortcut
            ln -s "$INSTALL_PATH" "$HOME/Desktop/Install Application"
            echo "-> Shortcut created at '$HOME/Desktop/Install Application'."
        else
            echo "-> Could not find '$HOME/Desktop'. Skipping shortcut creation."
        fi
    fi
    exit 0
fi

# --- Main Script Logic ---
# This part runs only when the script is called with arguments.
# It iterates through each argument, treating it as an executable to install.
echo "--- Application Installer Mode ---"

for app_path in "$@"; do
    # Check if the provided path is a valid, executable file
    if [ ! -f "$app_path" ] || [ ! -x "$app_path" ]; then
        echo "Warning: '$app_path' is not a valid executable file. Skipping."
        continue
    fi

    APP_NAME=$(basename "$app_path")
    APP_INSTALL_PATH="$INSTALL_DIR/$APP_NAME"
    APP_DESKTOP_FILE_NAME="$APP_NAME.desktop"
    APP_DESKTOP_FILE_PATH="$APPS_DIR/$APP_DESKTOP_FILE_NAME"

    echo "Installing '$APP_NAME'..."

    # 1. Copy the executable to the install directory and make it executable
    cp "$app_path" "$APP_INSTALL_PATH"
    chmod +x "$APP_INSTALL_PATH"
    echo "-> Copied executable to $APP_INSTALL_PATH"

    # 2. Create the .desktop file
    # We'll use the app name for the 'Name' field.
    # A generic icon is used as we can't guess the correct one.
    cat << EOF > "$APP_DESKTOP_FILE_PATH"
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=Custom installed application: $APP_NAME
Exec=$APP_INSTALL_PATH %F
Icon=application-x-executable
Terminal=false
Categories=Utility;
EOF
    echo "Installation of '$APP_NAME' complete."
    echo "-> To customize its name, icon, etc., you can edit the launcher file:"
    echo "   $APP_DESKTOP_FILE_PATH"
    echo
done

echo "--- All operations finished ---"
