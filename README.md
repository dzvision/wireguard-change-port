# wireguard-change-port

This repository contains scripts for changing the WireGuard port and updating firewall settings automatically.

## Recent Updates

### Merged Script (wg-change-port.sh)

We've merged the two firewall-specific scripts (`wg-change-port-firewalld.sh` and `wg-change-port-ufw.sh`) into a single, unified script: `wg-change-port.sh`.

#### Key Features:

1. **Unified Interface**: Single script that works with both firewalld and ufw
2. **Firewall Status Detection**: Automatically detects if firewalld or ufw is installed and active
3. **Security Group Support**: When firewalls are not active (common in cloud environments), it skips firewall rule updates and prompts users to update security group rules
4. **Random Port Generation**: Generates random ports between 1024-65535 when no port is specified
5. **Simplified Usage**: Consistent menu-driven interface

## Usage

### Using the Merged Script

## Usage

Download and execute the script. Answer the questions asked by the script and it will take care of the rest.

Option 1: WGET
```sh
wget -N --no-check-certificate https://raw.githubusercontent.com/dzvision/wireguard-change-port/main/wg-change-port.sh && chmod +x wg-change-port.sh && bash wg-change-port.sh
```

Option 2: CURL
```bash
curl -O https://raw.githubusercontent.com/dzvision/wireguard-change-port/main/wg-change-port.sh
chmod +x wg-change-port.sh
./wg-change-port.sh
```

3. Follow the menu prompts:
   - **Option 1**: Check the current WireGuard port
   - **Option 2**: Change the WireGuard port (enter a port or press Enter for random)
   - **Option 3**: Exit


