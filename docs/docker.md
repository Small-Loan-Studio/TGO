# Docker

- [Docker](#docker)
  - [TL;DR](#tldr)
  - [Setup](#setup)
  - [Usage](#usage)
    - [gdlint](#gdlint)
    - [gdformat](#gdformat)
    - [Command explanation](#command-explanation)

## TL;DR

Docker is a system that lets you configure a small virtual computer through
a file ([`Dockerfile`](../support/Dockerfile)) that can be used to run programs
in a deterministic environment on every machine.

## Setup

1. Download & Install the Docker Desktop platform for your machine: https://www.docker.com/
2. Once installed build the container for TGO in a shell from within the TGO repo checkout:  
   ```
   ~/Projects/TGO (envy-format-ci) $ docker build -t tgo:check -f support/Dockerfile .
   ```
   The initial build will take quite a while because it needs to:
   1. download a full linux install
   2. update the system
   3. install git, python, pip, and the gdscript toolkits

## Usage

Once the initial setup is done you should be able to run the GDscript tooling through docker.
Run the following commands from the root of your TGO checkout...

### gdlint

```
$ docker run -v .:/TGO/repo -ti tgo:check ./gdlint.sh
Success: no problems found
```

### gdformat

```
$ docker run -v .:/TGO/repo -ti tgo:check ./gdformat.sh
would reformat ./repo/Scripts/Components/Character.gd
would reformat ./repo/Scripts/Components/Detectable.gd
would reformat ./repo/Scripts/Components/Lamp.gd
would reformat ./repo/Scripts/Devin.gd
would reformat ./repo/Scripts/Enums.gd
would reformat ./repo/Scripts/Utils.gd
would reformat ./repo/ZZ_Scratch/Movement/CameraZoom2D.gd
would reformat ./repo/ZZ_Scratch/Movement/GrayBox.gd
would reformat ./repo/ZZ_Scratch/Movement/SpecialTree.gd
would reformat ./repo/ZZ_Scratch/Movement/TestMovement.gd
10 files would be reformatted, 0 files would be left unchanged.
```

### Command explanation
If you want we can take a second to understand what's being run:

- `docker` &mdash; this tells docker that we're about to request it to take some action with a container (virtual computer)
- `run` &mdash; the command that we want docker to do is "run" something with the container
- `-v .:/TGO/repo` &mdash; a special directory in the container has been declared as a `VOLUME`. This means we can configure, at execution, a directory from our computer to be reflected within the container.  
  The `-v` flag is saying "map the first directory to the second in the container." In this case `.` is "the current directory" and `/TGO/repo` is telling docker that we should make the contents of the current directory available at `/TGO/repo`
- `-ti` &mdash; not strictly necessary but if you wanted to run `bash` or anything that required interactivity you would need this so I'll often include it out of habit
- `tgo:check` &mdash; This is the name of the container to use. It should match the name given in `docker build`
- `./gdlint.sh`, `./gdformat.sh` &mdash; this is the command to run in the container. In this case these commands are specific to our TGO project and you can find what they do in [`gdlint.sh`](../support/gdlint.sh) and [`gdformat.sh`](../support/gdformat.sh). You can see where they get copied into the container in the [`Dockerfile`](../support/Dockerfile).