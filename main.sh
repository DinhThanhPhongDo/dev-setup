#!/bin/bash
# Development setup for Debian and Ubunto distros.
# https://github.com/DinhThanhPhongDo/dev-setup
#
# Copyright (c) Dinh Thanh Phong Do

# Regular colors
# ----------------
color_off='\033[0m'       # Text Reset
red='\033[0;31m'          # Red
green='\033[0;32m'        # Green
Green='\033[1;92m'        # Green
cyan='\033[1;96m'         # Cyan

# Add sources
# -----------
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $SCRIPT_DIR
. "${SCRIPT_DIR}"/libs/colors.sh
. "${SCRIPT_DIR}"/libs/check.sh
. "${SCRIPT_DIR}"/libs/github.sh
. "${SCRIPT_DIR}"/libs/gitlab.sh

platform=$(check_platform)
distro=$(check_distro) || { echo -e "${red}Unsupported distribution. Please provide a Debian/Ubuntu distribution${color_off}"; exit; }

echo -e "${green}Used platform: $platform${color_off}"
echo -e "${green}Used distribution: $distro${color_off}"
echo -e ""
echo -e "${Green}Remove and install...${color_off} "

# check platform
if [ "${platform}" = "wsl" ]; then
    source ${SCRIPT_DIR}/libs/wsl_env.sh
    setup_wsl_environment
fi

# check distro
if [ "${distro}" = "Debian" ] || [ "${distro}" = "Ubuntu" ]; then
    . ${SCRIPT_DIR}/libs/debian.sh
elif [ "${distro}" = "CentOS Stream" ] || [ "${distro}" = "Rocky Linux" ]; then
    . ${SCRIPT_DIR}/libs/red_hat.sh
else
    echo -e "${red}Unsupported distribution. Please provide a Debian/Ubuntu distribution${color_off}"
    exit 
fi

# install
remove
install

while true; do
    printf "${cyan}Do you want to set up github ssh? [y/n]: ${color_off}" && read answer

    case "$answer" in
        [yY]|[yY][eE][sS]) 
            echo -e "${Green}Set up github ssh...${color_off}"
            read -p "set the github username:" username
            read -p "set the github email:" email
            read -p "set the hostname [default: ssh.github.com]: " hostname
            read -p "set the port [default: 443]: " port
            setup_github_ssh "${username}" "${email}" "${hostname}" "${port}"
            break
            ;;
        [nN]|[nN][oO])
            echo -e "${Green}No action taken. Exiting...${color_off}"
            break
            ;;
        *)
            echo "Invalid input. Please enter 'y' or 'n'."
            ;;
    esac
done

while true; do
    printf "${cyan}Do you want to set up gitlab ssh? [y/n]: ${color_off}" && read answer

    case "$answer" in
        [yY]|[yY][eE][sS]) 
            echo -e "${Green}Set up gitlab ssh...${color_off}"
            read -p "set the git username:" username
            read -p "set the git email:" email
            read -p "set the hostname [default: gitlab.com]: " hostname
            read -p "set the port [default: 443]: " port
            setup_gitlab_ssh "${username}" "${email}" "${hostname}" "${port}"
            break
            ;;
        [nN]|[nN][oO])
            echo -e "${Green}No action taken. Exiting...${color_off}"
            break
            ;;
        *)
            echo "Invalid input. Please enter 'y' or 'n'."
            ;;
    esac
done

while true; do
    printf "${cyan}Do you want to install docker? [y/n]: ${color_off}" && read answer

    case "$answer" in
        [yY]|[yY][eE][sS]) 
            echo -e "${Green}Installing Docker...${color_off}"
            echo "${distro}"
            install_docker "${platform}" "${distro}"
            break
            ;;
        [nN]|[nN][oO])
            echo -e "${Green}No action taken. Exiting...${color_off}"
            break
            ;;
        *)
            echo "Invalid input. Please enter 'y' or 'n'."
            ;;
    esac
done
echo -e "${Green}Development machine sucessfully set up!${color_off}"
