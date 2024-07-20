FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y less python3-full python3-pip
RUN apt-get install -y git

RUN mkdir /TGO
WORKDIR /TGO
RUN python3 -m venv ./venv/
RUN ./venv/bin/pip install git+https://github.com/Scony/godot-gdscript-toolkit.git@f836958

RUN
COPY Scripts/ TGO/Scripts/
COPY ZZ_Scratch/ TGO/ZZ_Scratch/
COPY support/ .
CHMOD +x gdformat.sh
CHMOD +x gdlint.sh