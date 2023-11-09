#!/bin/bash

# Ask the user if they want to check the current WireGuard port
read -p "Do you want to check the current WireGuard port? (y/n) " CHECK_PORT

if [[ $CHECK_PORT =~ ^[Yy]$ ]]; then
  # Get the current WireGuard port from the config file
  WG_PORT=$(grep -oP '(?<=ListenPort = )\d+' /etc/wireguard/wg0.conf)

  # Show the current WireGuard port
  echo "The current WireGuard port is $WG_PORT."
fi

# Ask the user if they want to generate a random port
read -p "Do you want to generate a random WireGuard port? (y/n) " GENERATE_PORT

if [[ $GENERATE_PORT =~ ^[Yy]$ ]]; then
  # Generate a random port between 1024 and 65535
  NEW_PORT=$(shuf -i 1024-65535 -n 1)

  # Check if the new port is already in use by checking the firewall rule
  while [[ $(firewall-cmd --list-ports | grep -w $NEW_PORT/udp) ]]; do
    # Generate a new random port if the current one is already in use
    NEW_PORT=$(shuf -i 1024-65535 -n 1)
  done

  echo "Generated random port: $NEW_PORT"

  # Get the current WireGuard port from the config file
  WG_PORT=$(grep -oP '(?<=ListenPort = )\d+' /etc/wireguard/wg0.conf)

  # Update the WireGuard config file with the new port
  WG_CONFIG="/etc/wireguard/wg0.conf"
  sed -i "s/ListenPort = $WG_PORT/ListenPort = $NEW_PORT/" $WG_CONFIG

  # Reload the WireGuard config
  systemctl restart wg-quick@wg0.service

  # Remove the old firewall rule
  firewall-cmd --zone=public --remove-port=$WG_PORT/udp

  # Add the new firewall rule
  firewall-cmd --zone=public --add-port=$NEW_PORT/udp

  # Save the firewall configuration
  firewall-cmd --runtime-to-permanent

  # Show the current firewall rule for the new port
  echo "The current firewall rule for port $NEW_PORT is:"
  firewall-cmd --list-ports | grep -w $NEW_PORT/udp
fi
