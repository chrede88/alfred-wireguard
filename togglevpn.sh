#!/bin/bash

get_vpn_status() {
  local vpn=$1
  scutil --nc status "$vpn" | head -n 1 | grep -i "connected"
}

connect_vpn() {
  local vpn=$1
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
