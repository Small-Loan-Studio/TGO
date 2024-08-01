#!/bin/bash

args=$@

if [ -z "$args" ]; then
  find . -iname *.gd | xargs ./venv/bin/gdformat --check
else
  ./venv/bin/gdformat $args
fi
