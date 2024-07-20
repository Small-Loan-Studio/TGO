#!/bin/bash

args=$@

if [ -z "$args" ]; then
  args="--check"
fi

find . -iname *.gd | xargs ./venv/bin/gdformat $args