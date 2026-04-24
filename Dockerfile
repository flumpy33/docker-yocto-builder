# =============================================================================
# Yocto / OpenEmbedded Docker Builder
#
# Base  : crops/poky:debian-12  (Poky SDK + user-remapping machinery)
# Extras: KAS (Siemens, via PyPI) + Icecream distributed compiler (iceccd)
#
# Usage example:
#   docker build -t yocto-builder .
#
#   docker run --rm -it \
#     -v $(pwd):/workdir \
#     -v /path/to/icecc.conf:/etc/icecc/icecc.conf:ro \
#     yocto-builder \
#     --workdir=/workdir
# =============================================================================

FROM crops/poky:debian-12
USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        icecc \
        lbzip2 \
        python3-venv \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/kas && \
    /opt/kas/bin/pip install --upgrade pip && \
    /opt/kas/bin/pip install kas && \
    ln -sf /opt/kas/bin/kas /usr/local/bin/kas

RUN mkdir -p /etc/icecc /var/cache/icecc /var/log/icecc && \
    chmod 1777 /var/cache/icecc /var/log/icecc

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 10245/tcp
EXPOSE 8765/tcp

# Override the crops/poky ENTRYPOINT so our wrapper runs first.
# The CMD from crops/poky (poky-entry.py) is picked up by our wrapper and
# forwarded together with any arguments supplied on `docker run`.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
