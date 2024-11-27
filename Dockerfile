FROM crops/poky:debian-12

USER root

RUN apt update && apt install -y \
    python3-venv && apt autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install kas

USER usersetup

ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /workdir
