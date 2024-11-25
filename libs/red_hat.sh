#!/bin/bash
# Development setup for Debian and Ubuntu distros.
# https://github.com/DinhThanhPhongDo/dev-setup
#
# Copyright (c) Dinh Thanh Phong Do

# Regular Colors
# ----------------
color_off='\033[0m'       # Text Reset
red='\033[0;31m'          # Red
green='\033[0;32m'        # Green
Green='\033[1;92m'        # Green
cyan='\033[1;96m'         # Cyan

remove() {
    # Docstring:
    # This function uninstalls specified packages if they are installed on the system 
    # and performs a cleanup of unused dependencies.

    # List of packages to be checked and removed if installed
    for package in xclip ncdu htop tmux git; do
        # Check if the package is installed
        if yum list installed "${package}" >/dev/null 2>&1; then
            # Notify the user about the uninstallation process
            echo -e "${green}\\nUninstalling ${package}...${color_off}"
            # Uninstall the package
            sudo yum remove -q -y "${package}"
        fi
    done

    # Perform cleanup of unused dependencies
    echo -e "${green}\\nRemoving unused packages...${color_off}"
    sudo yum autoremove -q -y
}

install(){
    for package in xclip ncdu htop tmux git; do
        echo -e "${green}\\nInstall ${package}${color_off} "
        sudo yum check-update > /dev/null 2>&1
        sudo yum install -q -y "${package}"
    done
}

install_docker(){
    platform="$1"
    distro="$2"

    # 1) uninstall
    sudo dnf remove docker \
                    docker-client \
                    docker-client-latest \
                    docker-common \
                    docker-latest \
                    docker-latest-logrotate \
                    docker-logrotate \
                    docker-engine \
                    podman \
                    runc

    # 2) installing using the apt repository
    echo -e "${green}\nInstalling with ${distro} distro...${color_off}"
    # Add Docker's official GPG key:
    sudo dnf -y install dnf-plugins-core
    
    # 3) Install the Docker packages.
    if [ "${distro}" = "CentOS Stream" ]; then
        echo 0
        sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    else
        echo 1
        sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
        sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    fi

    # 4) Linux post-installation steps for Docker Engine
    # https://docs.docker.com/engine/install/linux-postinstall/
    sudo rm /var/run/docker.pid
    sudo systemctl enable --now docker
    # sudo dockerd
    sudo docker run hello-world
}
# install_docker