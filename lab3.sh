#!/bin/bash

# Function to execute a command and check if it succeeded
execute() {
    if ! "$@"; then
        echo "An error occurred executing \"$@\""
        exit 1
    fi
}

# Function to transfer and run configure-host.sh script on a remote server
configure_remote_server() {
    local server_address="$1"
    local hostname="$2"
    local ip_address="$3"
    local entry_name="$4"
    local entry_ip="$5"

    # Transfer configure-host.sh script to the remote server
    execute scp configure-host.sh remoteadmin@"$server_address":/root

    # Run configure-host.sh script on the remote server
    execute ssh remoteadmin@"$server_address" -- sudo /root/configure-host.sh -name "$hostname" -ip "$ip_address" -hostentry "$entry_name" "$entry_ip"
}

# Update local /etc/hosts file
update_local_hosts() {
    local entry_name="$1"
    local entry_ip="$2"

    # Run configure-host.sh locally
    execute sudo ./configure-host.sh -hostentry "$entry_name" "$entry_ip"
}

# Configure server1-mgmt
configure_remote_server "server1-mgmt" "loghost" "192.168.16.3" "webhost" "192.168.16.4"

# Configure server2-mgmt
configure_remote_server "server2-mgmt" "webhost" "192.168.16.4" "loghost" "192.168.16.3"

# Update local /etc/hosts file
update_local_hosts "loghost" "192.168.16.3"
update_local_hosts "webhost" "192.168.16.4"

echo "All operations completed successfully."
