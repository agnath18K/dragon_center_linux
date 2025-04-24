#!/bin/bash

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Error: Please run this script as root or with sudo."
    exit 1
fi

# Ensure required packages are installed
DEPS=(whiptail git x11-xserver-utils)
MISSING=()
for pkg in "${DEPS[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
        MISSING+=("$pkg")
    fi
done
if [ "${#MISSING[@]}" -ne 0 ]; then
    echo "🔄 Installing missing dependencies: ${MISSING[*]}"
    apt update
    apt install -y "${MISSING[@]}"
fi

# Ensure whiptail is available for modern ASCII UI
if ! command -v whiptail &>/dev/null; then
    echo "❌ Error: 'whiptail' is still not installed. Please install it (e.g., 'apt install whiptail') and retry."
    exit 1
fi

SERVICE_NAME="dragon-service.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"

# Install only the systemd service
install_service() {
    whiptail --title "Dragon Service Setup 🐉" --msgbox \
        "This wizard will help you configure and install the Dragon systemd service.\n\nIt requires:\n • Path to Dragon binary\n • Working directory\n • GUI environment variables for the desktop user." 15 60

    # Prompt for binary path
    BINARY_PATH=$(whiptail --inputbox \
        "Enter the full path to the Dragon binary:" 8 60 "/usr/local/lib/dragoncenter/dragon" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && exit 1

    # Prompt for working directory
    WORKING_DIR=$(whiptail --inputbox \
        "Enter the full path to the working directory:" 8 60 "/usr/local/lib/dragoncenter/" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && exit 1

    # Validate binary exists
    if [ ! -f "$BINARY_PATH" ]; then
        whiptail --title "Invalid Path" --msgbox \
            "Error: The binary path you provided does not exist:\n$BINARY_PATH" 10 60
        exit 1
    fi

    # Detect desktop user and GUI env
    ORIGINAL_USER=${SUDO_USER:-$(logname)}
    USER_HOME=$(eval echo "~$ORIGINAL_USER")
    USER_DISPLAY=$(sudo -u $ORIGINAL_USER echo $DISPLAY)
    USER_XAUTHORITY=$(sudo -u $ORIGINAL_USER echo ${XAUTHORITY:-$USER_HOME/.Xauthority})

    # Confirm configuration
    CONFIRM_MSG="Please confirm the following settings:\n\n"
    CONFIRM_MSG+=" • Dragon binary: $BINARY_PATH\n"
    CONFIRM_MSG+=" • Working directory: $WORKING_DIR\n"
    CONFIRM_MSG+=" • Run as user: root\n"
    CONFIRM_MSG+=" • GUI user: $ORIGINAL_USER\n"
    CONFIRM_MSG+=" • DISPLAY: $USER_DISPLAY\n"
    CONFIRM_MSG+=" • XAUTHORITY: $USER_XAUTHORITY"
    whiptail --title "Confirm Configuration ⚙️" --yesno "$CONFIRM_MSG" 20 60
    [ $? -ne 0 ] && {
        whiptail --title "Cancelled" --msgbox \
            "Installation cancelled.\nPlease rerun with correct values." 8 60
        exit 0
    }

    # Create service file
    cat <<EOF > "$SERVICE_PATH"
[Unit]
Description=Flutter Binary Service for Dragon
After=display-manager.service
Wants=display-manager.service

[Service]
Type=simple
# Run as root so the app has sudo privileges
User=root
# allow root to talk to the X session
ExecStartPre=/bin/bash -lc "xhost +SI:localuser:root"
# Optional delay to let everything settle
ExecStartPre=/bin/sleep 10
ExecStart=$BINARY_PATH
WorkingDirectory=$WORKING_DIR
Restart=always
RestartSec=5
Environment=DISPLAY=$USER_DISPLAY
Environment=XAUTHORITY=$USER_XAUTHORITY
ExecStop=/bin/kill -s SIGTERM \$MAINPID

[Install]
WantedBy=graphical.target
EOF

    # Reload, enable, and start
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME"
    systemctl start "$SERVICE_NAME"

    # Show service status
    systemctl status "$SERVICE_NAME" --no-pager > /tmp/dragon_status.txt
    whiptail --title "Service Status 📊" --textbox /tmp/dragon_status.txt 20 70

    whiptail --title "Success ✅" --msgbox \
        "Dragon service installed and started successfully!" 8 50
}

# Full install: driver, .deb, then service
full_install() {
    whiptail --title "Dragon Full Installer 🐉" --msgbox \
        "This will:\n 1) Install the ACPI EC driver\n 2) Add your user to 'ec' group\n 3) Install .deb package (if found)\n 4) Configure and start the Dragon service\n\nFollow the prompts to complete." 15 60

    # Step 1: ACPI EC driver
    whiptail --title "ACPI EC Driver" --msgbox \
        "Cloning and installing the ACPI EC driver from source." 10 50
    if [ ! -d "acpi_ec" ]; then
        git clone https://github.com/agnath18K/acpi_ec.git || {
            whiptail --title "Error" --msgbox \
                "Failed to clone acpi_ec repository." 8 50
            exit 1
        }
    fi
    cd acpi_ec || exit 1
    apt update
    apt install -y build-essential linux-headers-$(uname -r)
    ./install.sh || {
        whiptail --title "Error" --msgbox \
            "ACPI EC driver installation failed." 8 50
        exit 1
    }

    # Add user to ec group
    ORIGINAL_USER=${SUDO_USER:-$(logname)}
    if ! grep -q "^ec:" /etc/group; then
        groupadd ec
    fi
    if ! groups "$ORIGINAL_USER" | grep -q "\bec\b"; then
        usermod -a -G ec "$ORIGINAL_USER" || {
            whiptail --title "Error" --msgbox \
                "Failed to add $ORIGINAL_USER to 'ec' group." 8 50
            exit 1
        }
    fi
    cd ..

    # Step 2: .deb package
    DEB_PATH="debian/packages/dragoncenter_1.0.0_amd64.deb"
    if [ -f "$DEB_PATH" ]; then
        dpkg -i "$DEB_PATH" || {
            whiptail --title "Error" --msgbox \
                "Failed to install .deb package." 8 50
            exit 1
        }
    else
        whiptail --title "Package Not Found" --yesno \
            ".deb not found at $DEB_PATH. Skip package installation?" 10 60
        [ $? -ne 0 ] && {
            whiptail --title "Aborting" --msgbox \
                "Please ensure the .deb package exists and retry." 8 50
            exit 1
        }
    fi

    # Step 3: Service
    install_service

    # Cleanup
    rm -rf acpi_ec
    whiptail --title "Cleanup" --msgbox \
        "Temporary files and repositories have been removed." 8 50
}

# Uninstall everything
uninstall_dragon() {
    whiptail --title "Uninstall Dragon 🐉" --yesno \
        "This will stop and remove:
 • Dragon systemd service
 • ACPI EC driver
 • (optionally) /usr/local/lib/dragoncenter

Are you sure?" 15 60
    [ $? -ne 0 ] && {
        whiptail --title "Cancelled" --msgbox \
            "Uninstallation cancelled." 8 50
        exit 0
    }

    # Stop & disable service
    if [ -f "$ERVICE_PATH" ]; then
        systemctl stop "$SERVICE_NAME"
        systemctl disable "$SERVICE_NAME"
        rm -f "$SERVICE_PATH"
    fi
    systemctl daemon-reexec
    systemctl daemon-reload

    # Uninstall driver
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR" || exit 1
    git clone https://github.com/agnath18K/acpi_ec.git && cd acpi_ec
    if [ -f './uninstall.sh' ]; then
        chmod +x ./uninstall.sh
        ./uninstall.sh
    fi
    cd / && rm -rf "$TEMP_DIR"

    # Optional app directory cleanup
    whiptail --title "Remove App Files?" --yesno \
        "Do you want to delete /usr/local/lib/dragoncenter as well?" 10 60
    [ $? -eq 0 ] && rm -rf /usr/local/lib/dragoncenter

    # Final cleanup
    rm -rf acpi_ec
    whiptail --title "Done" --msgbox \
        "Uninstallation completed successfully." 8 50
}

# Main menu
CHOICE=$(whiptail --title "Dragon Installer Main Menu" --menu \
    "Select an option:" 15 60 4 \
    "install" "Full install (driver + .deb + service)" \
    "install-service" "Service-only install" \
    "uninstall" "Uninstall everything" \
    "exit" "Exit script" 3>&1 1>&2 2>&3)

case "$CHOICE" in
    install)
        full_install
        ;;
    install-service)
        install_service
        ;;
    uninstall)
        uninstall_dragon
        ;;
    exit)
        exit 0
        ;;
    *)
        exit 1
        ;;

esac

exit 0
