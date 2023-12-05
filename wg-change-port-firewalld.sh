#!/bin/bash

while true; do
  # Display menu options
  echo "Choose an option:"
  echo "1) Check Current WireGuard Port"
  echo "2) Change WireGuard Port"
  echo "3) Exit"

  # Read user input
  read -p "Enter your choice (1/2/3): " CHOICE

  case $CHOICE in
    1)
      # Check the current WireGuard port from the config file
      WG_PORT=$(grep -oP '(?<=ListenPort = )\d+' /etc/wireguard/wg0.conf)
      echo "The current WireGuard port is $WG_PORT."
      ;;
    2)
      # Ask the user for the desired port
      read -p "Enter the desired WireGuard port (leave blank for random): " NEW_PORT_INPUT

      if [[ -z $NEW_PORT_INPUT ]]; then
        # Generate a random port between 1024 and 65535
        NEW_PORT=$(shuf -i 1024-65535 -n 1)

        # Check if the new port is already in use by checking the firewall rule
        while [[ $(firewall-cmd --list-ports | grep -w $NEW_PORT/udp) ]]; do
          # Generate a new random port if the current one is already in use
          NEW_PORT=$(shuf -i 1024-65535 -n 1)
        done

        echo "Generated random port: $NEW_PORT"
      else
        # Use the user-provided port
        NEW_PORT=$NEW_PORT_INPUT
      fi

      # Check the current WireGuard port from the config file
      WG_PORT=$(grep -oP '(?<=ListenPort = )\d+' /etc/wireguard/wg0.conf)
      echo "The current WireGuard port is $WG_PORT."

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
      echo "The current firewall rule for port is: (WG Port $NEW_PORT)"
      firewall-cmd --list-ports | grep -w $NEW_PORT/udp
      ;;
    3)
      # Exit the script
      echo "Exiting..."
      exit 0
      ;;
    *)
      # Handle invalid input
      echo "Invalid choice. Please enter 1, 2, or 3."
      ;;
  esac
done

