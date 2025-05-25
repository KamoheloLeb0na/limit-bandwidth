#!/bin/bash

# Interface for CoovaChilli client traffic
IFACE="eth0"  # Change if needed (e.g., br-lan or wlan0)

USER_IP="$1"
SPEED_TIER="$2"

if [[ -z "$USER_IP" || -z "$SPEED_TIER" ]]; then
  echo "Usage: $0 <user_ip> <low|medium|high>"
  exit 1
fi

# Define speed limits per tier
case "$SPEED_TIER" in
  low)
    DL="512kbit"
    UL="256kbit"
    ;;
  medium)
    DL="2000kbit"
    UL="1000kbit"
    ;;
  high)
    DL="5000kbit"
    UL="2000kbit"
    ;;
  *)
    echo "Invalid speed tier: $SPEED_TIER"
    exit 1
    ;;
esac

# Clean existing rules for this user (optional)
tc filter del dev $IFACE protocol ip parent 1:0 prio 1 u32 match ip dst $USER_IP 2>/dev/null
tc filter del dev $IFACE parent ffff: protocol ip u32 match ip src $USER_IP 2>/dev/null

# Setup root qdisc if not already done
tc qdisc show dev $IFACE | grep -q "htb" || {
  tc qdisc add dev $IFACE root handle 1: htb default 12
  tc class add dev $IFACE parent 1: classid 1:1 htb rate 100mbit
}

# Add download shaper
tc class add dev $IFACE parent 1:1 classid 1:$(echo $USER_IP | tr '.' '_') htb rate $DL ceil $DL
tc filter add dev $IFACE protocol ip parent 1:0 prio 1 u32 match ip dst $USER_IP flowid 1:$(echo $USER_IP | tr '.' '_')

# Add upload shaper (policing ingress)
tc qdisc show dev $IFACE | grep -q "ingress" || tc qdisc add dev $IFACE handle ffff: ingress
tc filter add dev $IFACE parent ffff: protocol ip u32 match ip src $USER_IP police rate $UL burst 10k drop flowid :1

echo "Applied $SPEED_TIER tier to $USER_IP — DL: $DL / UL: $UL"
