#!/bin/bash

args="$@"

find . -iname *.gd -not -ipath './repo/addons/*' | xargs ./venv/bin/gdlint $args