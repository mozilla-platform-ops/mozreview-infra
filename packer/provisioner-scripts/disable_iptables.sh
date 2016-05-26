#!/bin/sh

sudo /etc/init.d/iptables stop
sudo chkconfig iptables off
sudo /etc/init.d/ip6tables stop
sudo chkconfig ip6tables off

