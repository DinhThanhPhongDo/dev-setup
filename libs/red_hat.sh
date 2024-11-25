#!/bin/bash

LIBS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "${LIBS_DIR}"/colors.sh

remove() {
    # Docstring:
    # This function uninstalls specified packages if they are installed on the system 
    # and performs a cleanup of unused dependencies.

    # List of packages to be checked and removed if installed
    for package in ncdu htop tmux git; do
        # Check if the package is installed
        if dnf list installed "${package}" >/dev/null 2>&1; then
            # Notify the user about the uninstallation process
            echo -e "${green}\\nUninstalling ${package}...${color_off}"
            # Uninstall the package
            sudo dnf remove -q -y "${package}"
        fi
    done

    # Perform cleanup of unused dependencies
    echo -e "${green}\\nRemoving unused packages...${color_off}"
    sudo dnf autoremove -q -y
}

install(){
    for package in ncdu htop tmux git; do
        echo -e "${green}\\nInstall ${package}${color_off} "
        sudo dnf check-update > /dev/null 2>&1
        sudo dnf install -q -y "${package}"
    done
}

install_docker(){
    platform="$1"
    distro="$2"
    # Dockstring:
    # This function installs Docker Engine on a Linux system using the DNF package manager. 
    # It is designed to handle distributions such as CentOS Stream and RHEL.
    #
    # Arguments:
    #   platform (str): The platform where Docker is being installed. Not explicitly used in the function.
    #   distro (str): The Linux distribution name (e.g., "CentOS Stream" or "RHEL") to tailor the repository configuration.
    #
    # Usage:
    #   install_docker "<platform>" "<distro>"
    #
    # Example:
    #   install_docker "Linux" "CentOS Stream"
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
    sudo dnf -q -y install dnf-plugins-core
    
    # 3) Install the Docker packages.
    if [ "${distro}" = "CentOS Stream" ]; then
        sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo dnf -q -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    else
        sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
        sudo dnf -q -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    fi

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

    # 4) Linux post-installation steps for Docker Engine
    # https://docs.docker.com/engine/install/linux-postinstall/
    if [ "${platform}" = "wsl" ]; then
        powershell.exe -Command "wsl --update"
    fi
    echo -e "${green}\\nPresss any button to test your docker...${color_off}"
    read continue

    sudo systemctl start docker
    sudo docker pull hello-world
    sudo docker run hello-world
}
