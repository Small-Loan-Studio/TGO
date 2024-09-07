FROM ubuntu:noble

RUN apt-get update
RUN apt-get install -y less python3-full python3-pip
RUN apt-get install -y git

RUN mkdir /TGO
WORKDIR /TGO
RUN python3 -m venv ./venv/
RUN ./venv/bin/pip install git+https://github.com/Scony/godot-gdscript-toolkit.git@f836958

RUN
COPY support/ .
RUN chmod +x gdformat.sh
RUN chmod +x gdlint.sh

VOLUME ./TGO/repo