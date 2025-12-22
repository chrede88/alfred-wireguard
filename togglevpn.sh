#!/bin/bash

get_vpn_status() {
  local vpn=$1
  scutil --nc status "$vpn" | head -n 1 | grep -i "connected"
}

disconnect_other_vpns() {
  local current_vpn="$1"
  
  # Get all VPNs with their statuses in one call to scutil
  scutil --nc list | grep "com.wireguard.macos" | while IFS= read -r line; do
    # Extract VPN name from quotes (format: ... "VPN_NAME" ...)
    vpn_name=$(echo "$line" | awk -F'"' '{print $2}')
    
    # Skip the current VPN that we're about to connect
    if [[ "$vpn_name" == "$current_vpn" ]]; then
      continue
    fi
    
    # Only disconnect VPNs that are currently connected
    if echo "$line" | grep -q "(Connected)"; then
      scutil --nc stop "$vpn_name"
	  sleep 1
    fi
  done
}

connect_vpn() {
  local vpn=$1
  
  # Check if we should turn off other VPNs
  # Convert to lowercase for comparison (compatible with bash 3.2)
  local env_value=$(echo "$is_turn_off_others" | tr '[:upper:]' '[:lower:]')
  if [[ "$env_value" =~ ^(true|1|yes|on)$ ]]; then
    disconnect_other_vpns "$vpn"
  fi
  
  scutil --nc start "$vpn"
}

disconnect_vpn() {
  local vpn=$1
  scutil --nc stop "$vpn"
}

toggle_vpn() {
  local vpn="$1"
  conn=$(get_vpn_status "$vpn")

  # toggle state
  if [[ "$conn" == "Connected" ]]; then
    disconnect_vpn "$vpn"
    echo "$vpn is disconnected"
  else
    connect_vpn "$vpn"
    echo "$vpn is connected"
  fi
}

# toggle state of {query}
toggle_vpn "$1"
