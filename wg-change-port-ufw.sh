#!/bin/bash

# Get the current WireGuard port from the config file
WG_PORT=$(grep -oP '(?<=ListenPort = )\d+' /etc/wireguard/wg0.conf)

# Show the current WireGuard port
echo "The current WireGuard port is $WG_PORT."

# Ask the user for the new port or press enter to generate a random port
read -p "Enter the new WireGuard port or press Enter to generate a random port: " NEW_PORT

# If the user didn't enter a new port, generate a random port
if [ -z "$NEW_PORT" ]; then
  # Generate a random port between 1024 and 65535
  NEW_PORT=$(shuf -i 1024-65535 -n 1)
  echo "Generated random port: $NEW_PORT"
fi

# Update the WireGuard config file with the new port
sed -i "s/ListenPort = $WG_PORT/ListenPort = $NEW_PORT/" /etc/wireguard/wg0.conf

# Reload the WireGuard config
systemctl restart wg-quick@wg0.service

# Ask the user if they want to update the firewall rule
read -p "Do you want to update the firewall rule? (y/n) " UPDATE_FIREWALL

if [[ $UPDATE_FIREWALL =~ ^[Yy]$ ]]; then
  # Remove the old firewall rule
  ufw delete allow $WG_PORT/udp

  # Add the new firewall rule
  ufw allow $NEW_PORT/udp

  # Enable ufw
  ufw --force enable
fi
                                                                                                           37        1,1           All
