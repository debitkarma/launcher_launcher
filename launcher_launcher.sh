#!/bin/bash

# A self-installing script to launch... launchers!
# Version: 0.3.1
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
readonly SCRIPT_VERSION="0.3.1"
readonly SCRIPT_NAME=$(basename "$0")
readonly INSTALL_DIR="$HOME/.local/bin"
readonly APPS_DIR="$HOME/.local/share/applications"

readonly INSTALL_PATH="$INSTALL_DIR/$SCRIPT_NAME"
# Use the script name without the .sh extension for the desktop file name
readonly DESKTOP_FILE_NAME="${SCRIPT_NAME%.sh}.desktop"
readonly DESKTOP_FILE_PATH="$APPS_DIR/$DESKTOP_FILE_NAME"

# --- Self-Installation Logic ---
# If the scipt is run without arguments, we assume it's being run for (un)installation,
# upgrade, or instructions.
if [ "$#" -eq 0 ]; then
    if [ -f "$INSTALL_PATH" ]; then
        echo "Launcher Launcher is already installed at $INSTALL_PATH."
        echo "What would you like to do?"
        echo "  [R]einstall (upgrade)"
        echo "  [U]ninstall"
        echo "  [I]nstructions and exit"
        read -p "Enter your choice [R/U/I]: " -n 1 -r
        echo
        case "$REPLY" in
            [Rr])
                # Compare version numbers between current script and installed script
                INSTALLED_VERSION_LINE=$(grep '^readonly SCRIPT_VERSION=' "$INSTALL_PATH" 2>/dev/null)
                if [[ $INSTALLED_VERSION_LINE =~ ^readonly\ SCRIPT_VERSION=\"([^\"]+)\" ]]; then
                    INSTALLED_VERSION="${BASH_REMATCH[1]}"
                else
                    INSTALLED_VERSION="unknown"
                fi

                if [ "$SCRIPT_VERSION" = "$INSTALLED_VERSION" ]; then
                    echo "-> Version is unchanged. Reinstalling."
                else
                    echo "-> Detected version change:"
                    echo "   Installed: $INSTALLED_VERSION"
                    echo "   New:       $SCRIPT_VERSION"
                    echo "-> Changing script and .desktop file."
                fi
                ;;
            [Uu])
                echo "-> Uninstalling..."
                rm -f "$INSTALL_PATH"
                rm -f "$DESKTOP_FILE_PATH"
                echo "-> Removed $INSTALL_PATH and $DESKTOP_FILE_PATH"
                echo "Uninstallation complete."
                exit 0
                ;;
            *)
                echo
                echo "Launcher Launcher is already installed."
                echo "To reinstall or upgrade to a new copy of this script, run this (new) script and choose 'R'."
                echo "To uninstall, run this script and choose 'U'."
                echo "To use launcher_launcher.sh:"
                echo "  - Drag and drop executable files onto the desktop shortcut to install them."
                echo "  - Or run this script with the paths to executables as arguments."
                echo "  Example:"
                echo "    $ $SCRIPT_NAME /path/to/executable1 /path/to/executable2"
                echo "If the files are not executable, you will be asked if you want to make them so."
                echo "If you opt not to, the file will be skipped."
                echo "If you need to change any details of the installed application (name, icon, etc.),"
                echo "you can edit the corresponding .desktop files which the script prints out for you."
                echo
                read -p "Press Enter to exit..." dummy
                exit 0
                ;;
        esac
    fi

    # 1. Ensure the target directories exist.
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$APPS_DIR"
    echo "-> Ensured directories exist: $INSTALL_DIR and $APPS_DIR"

    # 2. Copy this script to the installation path and make it executable.
    # If already running from ~/.local/bin/, skip copying and chmod
    if [ "$(dirname "$(realpath "$0")")" = "$INSTALL_DIR" ]; then
        echo "-> Script is already running from $INSTALL_DIR, reinstalling .desktop file only."
    else
        cp "$0" "$INSTALL_PATH"
        chmod +x "$INSTALL_PATH"
        echo "-> Script installed to $INSTALL_PATH"
    fi

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

    if [ ! -f "$app_path" ]; then
        echo "Warning: '$app_path' is not a valid file. Skipping."
        continue
    fi

    if [ ! -x "$app_path" ]; then
        read -p "'$app_path' is not executable. Mark as executable and continue? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            chmod +x "$app_path"
            echo "-> Marked '$app_path' as executable."
        else
            echo "Skipping '$app_path'."
            continue
        fi
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
    echo "-> To customize its name, version number, icon, etc., you can edit the launcher file:"
    echo "   $APP_DESKTOP_FILE_PATH"
    echo
done

echo "--- All operations finished ---"
