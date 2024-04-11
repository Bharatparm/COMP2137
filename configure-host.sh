#!/bin/bash

# Function to log changes

# Function to update hostname
newhostname() {
    local desired_name="$1"
    local current_name=$(hostname)
    if [ "$desired_name" != "$current_name" ]; then
        sudo hostnamectl set-hostname "$desired_name"
        sudo sed -i "s/$current_name/$desired_name/g" /etc/hosts
        sudo sed -i "s/$current_name/$desired_name/g" /etc/hostname
        log_changes "Hostname updated to $desired_name"
    fi
}



# Function to update /etc/hosts entry
updatehostentry() {
    local desired_name="$1"
    local desired_ip="$2"
    if ! grep -q "$desired_name" /etc/hosts; then
        echo "$desired_ip $desired_name" | sudo tee -a /etc/hosts > /dev/null
        log_changes "Added $desired_name with IP $desired_ip to /etc/hosts"
    fi
}

# Function to update IP address
updateip() {
    local desired_ip="$1"
    local current_ip=$(hostname -I | awk '{print $1}')
    if [ "$desired_ip" != "$current_ip" ]; then
        sudo sed -i "/$current_ip/c\\$desired_ip $HOSTNAME" /etc/hosts
        sudo sed -i "s/address .*/address $desired_ip/g" /etc/netplan/*.yaml
        sudo netplan apply
        log_changes "IP address updated to $desired_ip"
    fi
}
# Ignore signals
trap '' TERM HUP INT

# Parse command line arguments
VERBOSE=false
while [ "$#" -gt 0 ]; do
    case "$1" in
        -verbose) VERBOSE=true;;
        -name) update_hostname "$2"; shift;;
        -ip) update_ip "$2"; shift;;
        -hostentry) update_host_entry "$2" "$3"; shift 2;;
        *) echo "Unknown option: $1" >&2;;
    esac
    shift
done
