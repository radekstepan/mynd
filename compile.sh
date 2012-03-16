#!/bin/sh

echo 'export NODE_PATH="/usr/local/lib/node_modules/"' >> ~/.bashrc
clear
cake compile:widgets
exit $?