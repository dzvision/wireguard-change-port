#!/bin/bash

# Function to check and display the current WireGuard port
check_current_port() {
  WG_PORT=$(grep -oP '(?<=ListenPort = )\d+' /etc/wireguard/wg0.conf)
  echo "The current WireGuard port is $WG_PORT."
}

# Function to check firewall status and update rules if needed
update_firewall_rules() {
  local OLD_PORT=$1
  local NEW_PORT=$2
  
  # Check if firewalld is installed and running
  if command -v firewall-cmd &> /dev/null; then
    FIREWALLD_STATUS=$(systemctl is-active firewalld 2>/dev/null)
    if [[ $FIREWALLD_STATUS == "active" ]]; then
      echo "Updating firewalld rules..."
      # Remove the old firewall rule
      firewall-cmd --zone=public --remove-port=$OLD_PORT/udp
      
      # Add the new firewall rule
      firewall-cmd --zone=public --add-port=$NEW_PORT/udp
      
      # Save the firewall configuration
      firewall-cmd --runtime-to-permanent
      
      # Show the current firewall rule for the new port
      echo "The current firewall rule for port is: (WG Port $NEW_PORT)"
      firewall-cmd --list-ports | grep -w $NEW_PORT/udp
    else
      echo "firewalld is not active. Skipping firewall rule update."
      echo "Please update your security group rules to allow UDP port $NEW_PORT."
    fi
  # Check if ufw is installed and enabled
  elif command -v ufw &> /dev/null; then
    UFW_STATUS=$(ufw status | grep -E '^Status: (active|inactive)$' | cut -d' ' -f2)
    if [[ $UFW_STATUS == "active" ]]; then
      echo "Updating ufw rules..."
      # Remove the old firewall rule
      ufw delete allow $OLD_PORT/udp
      
      # Add the new firewall rule
      ufw allow $NEW_PORT/udp
      
      # Enable ufw
      ufw --force enable
      
      # Display the current firewall status
      ufw status
    else
      echo "ufw is not active. Skipping firewall rule update."
      echo "Please update your security group rules to allow UDP port $NEW_PORT."
    fi
  else
    echo "No supported firewall (firewalld or ufw) found. Skipping firewall rule update."
    echo "Please update your security group rules to allow UDP port $NEW_PORT."
  fi
}

# Function to change the WireGuard port
change_wireguard_port() {
  # Check the current WireGuard port from the config file
  WG_PORT=$(grep -oP '(?<=ListenPort = )\d+' /etc/wireguard/wg0.conf)
  echo "The current WireGuard port is $WG_PORT."

  # Ask the user for the desired port
  read -p "Enter the desired WireGuard port (leave blank for random): " NEW_PORT_INPUT

  if [[ -z $NEW_PORT_INPUT ]]; then
    # Generate a random port between 1024 and 65535
    NEW_PORT=$(shuf -i 1024-65535 -n 1)
    echo "Generated random port: $NEW_PORT"
  else
    # Use the user-provided port
    NEW_PORT=$NEW_PORT_INPUT
  fi

  # Update the WireGuard config file with the new port
  WG_CONFIG="/etc/wireguard/wg0.conf"
  sed -i "s/ListenPort = $WG_PORT/ListenPort = $NEW_PORT/" $WG_CONFIG

  # Reload the WireGuard config
  systemctl restart wg-quick@wg0.service

  # Update firewall rules if needed
  update_firewall_rules $WG_PORT $NEW_PORT
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
      echo "Port changed successfully. Exiting..."
      exit 0
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