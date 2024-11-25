#!/bin/bash

setup_wsl_environment() {
    # Docstring:
    # This function installs the necessary packages for a WSL environment and ensures that systemd 
    # is enabled as the init system. If systemd is not already configured, it updates the WSL 
    # configuration file and shuts down WSL to apply the changes.

    # List of packages to be installed in WSL
    for package in wsl; do
        echo -e "${green}\\nInstalling ${package}...${color_off}"
        sudo apt update -y && sudo apt install -y "${package}"
    done

    # Check if systemd is already enabled in the WSL configuration
    if grep -q "[boot]" /etc/wsl.conf; then
        echo -e "${green}System has been booted with systemd. Nothing to do.${color_off}"
    else
        # Append systemd configuration to /etc/wsl.conf
        printf "[boot]\nsystemd=true" | sudo tee -a /etc/wsl.conf > /dev/null
        echo -e "${green}System has not been booted with systemd as the init system. Enabling systemd...${color_off}"

        # Shutdown WSL to apply systemd configuration
        echo -e "${green}Shutting down WSL. Please restart WSL and re-run the script to complete the installation...${color_off}"
        powershell.exe -Command "wsl --shutdown"
    fi
}
