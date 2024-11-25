#!/bin/bash

LIBS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "${LIBS_DIR}"/colors.sh

setup_gitlab_ssh(){
    user_name="${1}"
    user_email="${2}"
    host_name="${3:-ssh.github.com}"
    port="${4:-443}"

    git config --global user.name "${user_name}"
    git config --global user.email "${user_email}"
    git config --global core.editor "vim"

    ALGORITHM="ed25519"
    PASSPHRASE=""

    # 1) if necessary, create a key pair
    if [ -f "${HOME}/.ssh/gitlab" ] && [ -f "${HOME}/.ssh/gitlab.pub" ]; then
        echo -e "${green}SSH keys already exist. Nothing to do.${color_off}"
    else
        # Create SSH key pair
        ssh-keygen -t "${ALGORITHM}" -f "${HOME}/.ssh/gitlab" -N "${PASSPHRASE}"
        echo -e "${green}New SSH key pair generated.${color_off}"
    fi

    # 2) add to the machine ssh agent
    eval $(ssh-agent -s)
    ssh-add "${HOME}/.ssh/gitlab"

    # 3) add a config for the gitlab host
    # Path to the SSH config file
    ssh_config="$HOME/.ssh/config"

    # Content to be written to the config file
    config_content="Host $hostname
        User $username
        Hostname $hostname
        PreferredAuthentications publickey
        IdentityFile ~/.ssh/gitlab
        Port $port
        AddKeysToAgent yes
    "

    # Check if the SSH config file already exists
    if [ -f "$ssh_config" ]; then
        # If it exists, override the data for the 'gitlab.com' host
        sed -i '/^Host gitlab.com/,/^$/d' "$ssh_config"
    fi

    # Append the new content to the SSH config file
    echo "$config_content" >> "$ssh_config"

    # Set appropriate permissions for the SSH config file
    chmod 600 "$ssh_config"
    echo -e "${green}Please copy-paste your public key to your host:${color_off}"

    # 4) add publickey to gitlab host
    # https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?platform=linux&tool=webui
    cat "${HOME}/.ssh/gitlab.pub"

    # 4) test ssh config
    echo -e "${green}Press any button to test your gitlab ssh config...${color_off}"
    read continue
    ssh -T "git@${hostname}"

    return 1
}
