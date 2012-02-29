#!/bin/sh

compile() {
    coffee --compile widgets.coffee
}

daemon() {
    chsum1=""
    while [ true ]
    do
        chsum2=`md5sum widgets.coffee`
        if [ "$chsum1" != "$chsum2" ] ; then
            echo "$chsum1 != $chsum2"
            compile
            chsum1=`md5sum widgets.coffee`
        fi
        sleep 2
    done
}

if [ "$1" = "-d" ] ; then
    daemon
else
    compile
fi