#!/bin/bash

args="$@"

find . -iname *.gd | xargs ./venv/bin/gdlint $args