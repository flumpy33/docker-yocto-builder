# Docker Yocto builder

This repository contains the docker build script to create a docker image base
on crops/poky:debian-12. The following modifications have been made:

1. python venv is installed & created,
2. kas has been installed by means of pip.

Read the [Poky container](https://github.com/crops/poky-container) or
[Yocto project](https://docs.yoctoproject.org/4.0.22/dev-manual/start.html?highlight=crops#setting-up-to-use-cross-platforms-crops)
regarding specific usage of the docker image. Kas documentation can be found
[here](https://kas.readthedocs.io/en/latest/).

## How to use kas and docker

Clone the repository that contains the kas files, most likely it is something that
is already part of the meta-layer, e.g. meta-layer/conf/kas-files/<thing>.yaml.
To instruct docker to run the command just do the following:

```bash
docker run -it -v $(pwd):/workdir -v thesoftwareengineer83/debian-12-kas:latest \
    --workdir=/workdir bash -c "kas build <thing>.yaml"
```

This will start by downloading the docker image if not already executed and executes
the bash command, exit code can be caught to determine the build result.

## How to use icecc

The docker machine contains the icecream distributed compile (icecc), which can be used the speed up the builds.
Docker machine will require some settings to get the icecc running as you desire, this can be done by passing the
config file with the invocation of docker. See the following example, will require some tweaking on your end:

```bash
docker run -it -v $(pwd):/workdir -v thesoftwareengineer83/debian-12-kas:latest \
    -v <some location>/iceccd.conf:/etc/icecc/icecc.conf:ro \
    --workdir=/workdir bash -c "kas build <thing>.yaml"
```
The iceccd.conf should atleast contain the following variables (remember these are just per example,
yours might be different):

```bash
ICECC_SCHEDULER_HOST="192.168.1.10"
ICECC_MAX_JOBS=8
ICECC_NETNAME="mybuild"
ICECC_NICE_LEVEL=5
```

# License

MIT License Copyright (c) 2024 J Simons
