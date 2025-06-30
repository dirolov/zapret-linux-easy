#!/bin/bash

if pidof "nfqws" > /dev/null; then
    killall nfqws
fi

iptables -t mangle -F PREROUTING
iptables -t mangle -F POSTROUTING
