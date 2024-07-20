#!/bin/bash

find . -iname *.gd | xargs ./venv/bin/gdformat --check