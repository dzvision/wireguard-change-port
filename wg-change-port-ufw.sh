#!/bin/bash

# Function to check and display the current WireGuard port
check_current_port() {
  WG_PORT=$(grep -oP '(?<=ListenPort = )\d+' /etc/wireguard/wg0.conf)
  echo "The current WireGuard port is $WG_PORT."
}

# Function to change the WireGuard port
change_wireguard_port() {
  check_current_port

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

  # Remove the old firewall rule
  ufw delete allow $WG_PORT/udp

  # Add the new firewall rule
  ufw allow $NEW_PORT/udp

  # Enable ufw
  ufw --force enable

  # Display the current firewall status
  ufw status
}

# Main menu
while true; do
  echo "WireGuard Configuration Menu:"
  echo "1) Check Current Port"
  echo "2) Change WireGuard Port"
  echo "3) Exit"

  read -p "Enter your choice (1-3): " CHOICE

  case $CHOICE in
    1)
      check_current_port
      ;;
    2)
      change_wireguard_port
      ;;
    3)
      echo "Exiting WireGuard Configuration Menu."
      exit 0
      ;;
    *)
      echo "Invalid choice. Please enter a number between 1 and 3."
      ;;
  esac
done