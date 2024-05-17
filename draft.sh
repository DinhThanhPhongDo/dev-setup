#!/bin/bash
# Development setup for Red Hat distros.
# https://github.com/DinhThanhPhongDo/dev-setup
#
# Copyright (c) Dinh Thanh Phong Do

# Regular Colors
# ----------------
color_off='\e[0m'       # Text Reset
red='\033[0;31m'          # Red
green='\e[32m'        # Green
Green='\033[1;92m'        # Green
cyan='\033[1;96m'         # Cyan


# check linux version
# -------------------
check_platform() {
    if grep -qi microsoft /proc/version; then
        platform="wsl"
    else
        platform="native"
    fi

    echo ${platform}
    return 0
}


# install / remove packages
# -------------------------

remove(){
    for package in xclip ncdu htop tmux git; do
        if yum list installed "${package}" >/dev/null 2>&1; then
            # y = less noisy and assume yes
            echo "${green}\\nUninstall ${package}...${color_off}"
            # echo "sudo yum remove -y "${package}""
            sudo yum remove -y "${package}"
        fi
    done

    echo "${green}\\nUninstall unused packages...${color_off}"
    sudo yum autoremove -y
}

install_native(){
    for package in xclip; do
        echo "${green}\\nInstall ${package}...${color_off}"
        sudo yum check-update > /dev/null 2>&1
        sudo yum install -y "${package}"
    done
}

install_distro(){
    for package in ncdu htop tmux git; do
        echo "${green}\\nInstall ${package}${color_off} "
        sudo yum check-update > /dev/null 2>&1
        sudo yum install -y "${package}"
    done
}

setup_github_ssh(){
    platform="${1}"
    user_name="${2}"
    user_email="${3}"

    git config --global user.name "${user_name}"
    git config --global user.email "${user_email}"
    git config --global core.editor "vim"

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
    if [ "${platform}" = "wsl" ]; then
        cat "${HOME}/.ssh/github.pub" | clip.exe
    else
        cat "${HOME}/.ssh/github.pub" | xclip
    fi

    # 4) test ssh config
    echo "${green}Press any button to test your github ssh config...${color_off}"
    read continue
    ssh -T git@github.com

    return 1
}

install_native
install_distro
remove
# P="tmux"
# sudo yum remove tmux