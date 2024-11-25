check_platform() {
    # Docstring: 
    # This function checks the current platform type by analyzing the kernel version string.
    # If the system is running on Windows Subsystem for Linux (WSL), it sets `platform` to "wsl".
    # Otherwise, it sets `platform` to "native".
    #
    # Returns:
    # - The platform type ("wsl" or "native") is echoed to the standard output.

    # Check if "microsoft" is mentioned in the kernel version, which indicates WSL
    if grep -qi microsoft /proc/version; then
        # Set the platform to "wsl" if the system is running on WSL
        platform="wsl"
    else
        # Set the platform to "native" for a non-WSL environment
        platform="native"
    fi

    # Output the determined platform type
    echo ${platform}

    # Return 0 to indicate success
    return 0
}

check_distro() {
    # Docstring:
    # This function checks the Linux distribution name by reading the `/etc/os-release` file.
    # If the file exists and the distribution name is found, it outputs the name (e.g., "Ubuntu", "CentOS").
    #
    # Returns:
    # - The distribution name is echoed to the standard output if available.
    # - Returns 0 if the file `/etc/os-release` exists and the distribution name is found.
    # - Returns 1 if the file `/etc/os-release` does not exist.

    # Check if the `/etc/os-release` file exists, which contains distro information
    if [ -f /etc/os-release ]; then
        # Source the `/etc/os-release` file to extract variables like $NAME
        . /etc/os-release

        # If the $NAME variable is set (contains the distribution name), print it
        if [ -n "$NAME" ]; then
            echo "$NAME"
        fi

        # Indicate success since the file exists and was processed
        return 0
    else
        # If `/etc/os-release` is missing, return failure status (1)
        return 1
    fi
}
