#!/bin/bash

get_vpn_names() {
  scutil --nc list | grep "com.wireguard.macos" | awk -F'"' '{print$2}' | sort
}

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

wait_for_disconnect() {
    local vpn=$1
    status=$(get_vpn_status "$vpn")

    timeout=0
    while [ "$status" != "Connected" ]
    do
        sleep 0.5
        timeout=$(echo $timeout + 0.5 | bc)
        if [ timeout > 5 ]; then
            break
        fi
        status=$(get_vpn_status "$vpn")
    done
}

toggle_vpn() {
  local new_vpn="$1"
  conn=$(get_vpn_status "$new_vpn")

  IFS=$'\n' read -r -d '' -a vpns < <( get_vpn_names && printf '\0' )

  # toggle state
  if [ "$conn" = "Connected" ]; then
    disconnect_vpn "$new_vpn"
    echo "$new_vpn is disconnected"
  else
    # check if other connection are open and close them first
    for vpn in "${vpns[@]}";do
      conn_old=$(get_vpn_status "$vpn")
      if [ "$conn_old" = "Connected" ]; then
        disconnect_vpn "$vpn"
        wait_for_disconnect "$vpn"
      fi
    done

    connect_vpn "$new_vpn"
    echo "$new_vpn is connected"
  fi
}

# toggle state of {query}
toggle_vpn "$1"
