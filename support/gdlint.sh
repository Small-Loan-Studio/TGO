#!/bin/bash

args="$@"

find . -iname *.gd -not -ipath './addons/*' | xargs ./venv/bin/gdlint $args