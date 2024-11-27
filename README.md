Docker Yocto builder
====================

This repository contains the docker build script to create a docker image base
on crops/poky:debian-12. The following modifications have been made:

1. python venv is installed & created,
2. kas has been installed by means of pip.

Read the [Poky container](https://github.com/crops/poky-container) or [Yocto project](https://docs.yoctoproject.org/4.0.22/dev-manual/start.html?highlight=crops#setting-up-to-use-cross-platforms-crops) regarding specific usage
of the docker image. Kas documentation can be found
[here](https://kas.readthedocs.io/en/latest/).

How to use kas and docker
-------------------------

Clone the repository that contains the kas files, most likely it is something that
is already part of the meta-layer, e.g. meta-layer/conf/kas-files/<thing>.yaml.
To instruct docker to run the command just do the following:

```bash
docker run -it -v $(pwd):/workdir -v thesoftwareengineer83/debian-12-kas:latest \
    --workdir=/workdir bash -c "kas build <thing>.yaml"
```

This will start by downloading the docker image if not already executed and executes
the bash command, exit code can be caught to determine the build result.
