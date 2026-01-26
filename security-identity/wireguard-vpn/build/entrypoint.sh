#!/bin/bash
set -e

awk -v key="$(cat /etc/wireguard-secret/privatekey)" '
/^\[Interface\]$/ {print; print "PrivateKey = " key; next}1' \
/etc/wireguard-config/wg0.conf.template > /etc/wireguard/wg0.conf

wg-quick up wg0

sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT

sleep infinity