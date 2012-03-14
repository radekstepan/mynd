#!/bin/sh

coffee --watch --compile --output js/ src/ &
coffee --watch --compile test/spec.coffee &