FROM python:slim

RUN apt-get update && apt-get install -y git less && rm -rf /var/lib/apt/lists/*

WORKDIR /tgo
ENV PATH=/tgo:$PATH
RUN python -m pip install git+https://github.com/Scony/godot-gdscript-toolkit.git@e9ec1f52d9c837dba440987ba50540f14beb7cad
COPY ./support/gdformat.sh gdformat
COPY ./support/gdlint.sh  gdlint
