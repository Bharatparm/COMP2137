#!/bin/bash

# This script runs the configure-host.sh script from the current directory to modify 2 servers and update the local /etc/hosts file

# Function to execute a command and check if it succeeded
execute() {
    if ! "$@"; then
        echo "An error occurred executing \"$@\""
        exit 1
    fi
}

# Transfer configure-host.sh script to the remote servers
execute scp configure-host.sh remoteadmin@server1-mgmt:/root
execute scp configure-host.sh remoteadmin@server2-mgmt:/root

# Run configure-host.sh script on the remote servers
if [ "$1" = "-verbose" ]; then
    execute ssh -v remoteadmin@server1-mgmt -- sudo /root/configure-host.sh -name loghost -ip 192.168.16.3 -he webhost 192.168.16.4
    execute ssh -v remoteadmin@server2-mgmt -- sudo /root/configure-host.sh -name webhost -ip 192.168.16.4 -he loghost 192.168.16.3
else
    execute ssh remoteadmin@server1-mgmt -- sudo /root/configure-host.sh -name loghost -ip 192.168.16.3 -he webhost 192.168.16.4
    execute ssh remoteadmin@server2-mgmt -- sudo /root/configure-host.sh -name webhost -ip 192.168.16.4 -he loghost 192.168.16.3
fi

# Run configure-host.sh script locally
if [ "$1" = "-verbose" ]; then
    ./configure-host.sh -v -hostentry loghost 192.168.16.3
    ./configure-host.sh -v -hostentry webhost 192.168.16.4
else
    ./configure-host.sh -hostentry loghost 192.168.16.3
    ./configure-host.sh -hostentry webhost 192.168.16.4
fi

echo "All operations completed successfully."
