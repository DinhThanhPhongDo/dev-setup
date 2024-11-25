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

remove(){
    for package in xclip ncdu htop tmux git; do
        if ! command -v "${package}" &> /dev/null; then
            # y = less noisy and assume yes
            echo -e "${green}\\nUninstall ${package}...${color_off}"
            sudo apt remove -y "${package}"
        fi
    done

    echo "${green}\\nUninstall unused packages...${color_off}"
    sudo apt autoremove -y
}

install(){
    for package in xclip ncdu htop tmux git; do
        echo -e "${green}\\nInstall ${package}${color_off} "
        sudo apt update -y && sudo apt install -y "${package}"
    done
}

install_docker(){
    platform="$1"
    distro="$2"
    

    # 1) uninstall
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        echo -e "${green}\\nUninstall ${pkg}...${color_off}"
        sudo apt-get update -y && sudo apt-get remove $pkg -y;
    done

    # 2) installing using the apt repository
    echo -e "${green}\nInstalling with ${distro} distro...${color_off}"
    # Add Docker's official GPG key:
    sudo apt-get update -y && sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    if [ "${distro}" = "Debian GNU/Linux" ]; then
        sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add the repository to Apt sources:
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update


    else
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add the repository to apt sources:
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi

    # 3) Install the Docker packages.
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 4) Linux post-installation steps for Docker Engine
    # https://docs.docker.com/engine/install/linux-postinstall/


    # Check if the "docker" group exists
    if ! grep -q "^docker:" /etc/group; then
        sudo groupadd docker
    fi

    # Check if the current user is a member of the "docker" group
    if ! groups "${USER}" | grep -q '\bdocker\b'; then
        sudo usermod -aG docker "${USER}"
        newgrp docker
    fi

    # 5) Verify that the Docker Engine installation is successful by running the hello-world image.
    # https://askubuntu.com/questions/1379425/system-has-not-been-booted-with-systemd-as-init-system-pid-1-cant-operate
    if [ "${platform}" = "wsl" ]; then
        powershell.exe -Command "wsl --update"
    fi
    echo -e "${green}\\nPresss any button to test your docker...${color_off}"
    read continue
    sudo systemctl start docker
    sudo docker pull hello-world:latest
    sudo docker run hello-world:latest
}