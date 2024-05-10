#!/bin/bash
# Development setup 
# https://github.com/DinhThanhPhongDo/dev-setup
#
# Copyright (c) Dinh Thanh Phong Do
export DEBIAN_FRONTEND=noninteractive


# Regular Colors
----------------
color_off='\033[0m'       # Text Reset
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
green='\033[0;32m'        # Green
Green='\033[1;92m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
cyan='\033[1;96m'         # Cyan
White='\033[0;37m'        # White

# check linux version
# -------------------
check_linux_version() {
    if grep -qi microsoft /proc/version; then
        echo "wsl"
    else
        echo "native"
    fi
}

# install function
# ----------------
remove(){

    for package in xclip ncdu tmux git; do
        if ! command -v "${package}" &> /dev/null; then
            # y = less noisy and assume yes
            echo "${green}\\nUninstall ${package}...${color_off}"
            sudo apt remove -y "${package}"
        fi
    done

    sudo apt autoremove -y
}

install_native(){
    for package in xclip ncdu tmux git; do
        echo "${green}\\nInstall ${package}${color_off}"
        sudo apt update -y && sudo apt install -y "${package}"
    done
}

install_wsl(){
    for package in wsl ncdu tmux git; do
        echo "${green}\\nInstall ${package}${color_off} "
        sudo apt update -y && sudo apt install -y "${package}"
    done
}

install_docker(){
    linux_version="$1"
    

    # 1) uninstall
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        sudo apt-get update -y && sudo apt-get remove $pkg -y;
    done

    # 2) installing using the apt repository
    # Add Docker's official GPG key:
    sudo apt-get update -y && sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    # Add the repository to apt sources:
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    

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
    if [ "${linux_version}" = "wsl" ]; then
        powershell.exe -Command "wsl --update"
    fi
    sudo systemctl start docker
    sudo docker pull hello-world:latest
    sudo docker run hello-world:latest
}

setup_github_ssh(){
    linux_version="$1"
    user_name="$2"
    user_email="$3"

    git config --global user.name "${user_name}"
    git config --global user.email "${user_email}"

    ALGORITHM="ed25519"
    PASSPHRASE=""

    # 1) if necessary, create a key pair
    if [ -f "${HOME}/.ssh/github" ] && [ -f "${HOME}/.ssh/github.pub" ]; then
        echo "${green}SSH keys already exist. Nothing to do.${color_off}"
    else
        # Create SSH key pair
        ssh-keygen -t "${ALGORITHM}" -f "${HOME}/.ssh/github" -N "${PASSPHRASE}"
        echo "${green}New SSH key pair generated.${color_off}"
    fi

    # 2) add to the machine ssh agent
    eval $(ssh-agent -s)
    ssh-add "${HOME}/.ssh/github"

    # 3) add a config for the github host
    # Path to the SSH config file
    ssh_config="$HOME/.ssh/config"

    # Content to be written to the config file
    config_content="Host github.com
        User git
        Hostname ssh.github.com
        PreferredAuthentications publickey
        IdentityFile $HOME/.ssh/github
        port 443
    "

    # Check if the SSH config file already exists
    if [ -f "$ssh_config" ]; then
        # If it exists, override the data for the 'github.com' host
        sed -i '/^Host github.com/,/^$/d' "$ssh_config"
    fi

    # Append the new content to the SSH config file
    echo "$config_content" >> "$ssh_config"

    # Set appropriate permissions for the SSH config file
    chmod 600 "$ssh_config"
    # 4) add publickey to github host
    # https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?platform=linux&tool=webui
    if [ "${linux_version}" = "wsl" ]; then
        cat "${HOME}/.ssh/github.pub" | clip.exe
    else
        cat "${HOME}/.ssh/github.pub" | xclip
    fi

    # 4) test ssh config
    echo "${green}test your github ssh config...${color_off}"
    ssh -T git@github.com

}


# script
# --------------
linux_version=$(check_linux_version)
echo "${Green}remove and install...${color_off} "

if [ "${linux_version}" = "native" ]; then
    remove
    install_native
else
    remove
    install_wsl
fi
while true; do
    printf "${cyan}Do you want to set up github ssh? [y/n]:${color_off}"
    read answer
    case "$answer" in
        [yY]|[yY][eE][sS]) 
            echo "${Green}set up github ssh...${color_off}"
            read -p "set the git username:" username
            read -p "set the git email:" email
            setup_github_ssh "${linux_version}" "${username}" "${email}"
            break
            ;;
        [nN]|[nN][oO])
            echo "${Green}No action taken. Exiting...${color_off}"
            break
            ;;
        *)
            echo "Invalid input. Please enter 'y' or 'n'."
            ;;
    esac
done

while true; do
    printf "${cyan}Do you want to set up github ssh? [y/n]:${color_off}"
    read answer
    case "$answer" in
        [yY]|[yY][eE][sS]) 
            echo "${Green}Installing Docker...${color_off}"
            install_docker "${linux_version}"
            break
            ;;
        [nN]|[nN][oO])
            echo "${Green}No action taken. Exiting...${color_off}"
            break
            ;;
        *)
            echo "Invalid input. Please enter 'y' or 'n'."
            ;;
    esac
done
