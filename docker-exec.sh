#!/bin/bash

gearname=$1
shift

containerid=`docker ps | grep $gearname | awk '{print $1}'`
echo "Container $containerid" 1>&2

lxcpid=`ps -ef | grep "lxc-start -n c501837eaf17" | grep -v grep | awk '{print $2}'`
echo "Lxc pid $lxcid" 1>&2

nspid=`pgrep -P $lxcpid`
echo "Namespace pid $nspid" 1>&2

#nsenter -m -u -n -i -p -t $nspid "$@"
if [ "$1" == "SNAT" ]; then
    cmd="ip -4 addr show dev eth0 scope global | sed -r -n '/inet/ { s/^.*inet ([0-9\    .]+).*/\1/; p }' | head -1"
    /usr/local/bin/nsexec /proc/$nspid/ns/net "$cmd"
else
    args="$@"
    /usr/local/bin/nsexec /proc/$nspid/ns/net "$args"
fi
