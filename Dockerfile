# syntax=docker/dockerfile:1

# Build Arguments
ARG KLIPPERSCREEN_URL="https://github.com/jordanruthe/KlipperScreen"
# ARG KLIPPERSCREEN_VERSION="heads/master"
ARG KLIPPERSCREEN_REF="tags/v0.3.1"



# Build Stage
FROM python:3 as build

# Re-export the build arguments
ARG KLIPPERSCREEN_URL
ARG KLIPPERSCREEN_REF

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
      libgirepository1.0-dev \
      libdbus-glib-1-dev \
      cmake && \
    apt-get clean

# Set default working directory
WORKDIR /opt/klipperscreen

# Download KlipperScreen
RUN mkdir -p /opt/klipperscreen/KlipperScreen && \
    curl -sL ${KLIPPERSCREEN_URL}/archive/refs/${KLIPPERSCREEN_REF}.tar.gz | tar -zxvf - -C KlipperScreen --strip-components=1

# Create a virtual Python environment for KlipperScreen
RUN python -m venv venv

# Install KlipperScreen dependencies
RUN venv/bin/pip install -r KlipperScreen/scripts/KlipperScreen-requirements.txt



# Run Stage
FROM python:3-slim as run

# Set default environment variables
ENV XAUTHORITY="/tmp/.Xauthority"
ENV DISPLAY=":0"
ENV PULSE_SERVER=""
ENV KLIPPERSCREEN_RESTART_DELAY="60"

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
      git \
      curl \
      bash \
      xdotool \
      x11-xserver-utils \
      libglib2.0-0 \
      libgirepository-1.0-1 \
      gir1.2-gtk-3.0 \
      libopenjp2-7 \
      fonts-freefont-ttf \
      libcairo2 \
      libatlas3-base \
      libdbus-glib-1-2 && \
    apt-get clean

# Set default working directory
WORKDIR /opt/klipperscreen

# Copy KlipperScreen and the virtual python environment from the build stage
COPY --from=build /opt /opt

# Define volumes
VOLUME [ "/opt/klipperscreen/config" ]

# Create a custom wrapper script for handling KlipperScreen restarts and graceful exits
RUN echo '#!/usr/bin/env bash' > /opt/klipperscreen/start.sh && \
    echo 'set -x' && \
    echo 'trap "echo; echo \"NOTICE: Exit signal received, terminating ...\"; exit 0" SIGINT SIGTERM' >> /opt/klipperscreen/start.sh && \
    echo 'while true; do' >> /opt/klipperscreen/start.sh && \
    echo '  echo' && \
    echo '  echo "NOTICE: Starting KlipperScreen ..."' && \
    echo '  cd /opt/klipperscreen' && \
    echo '  /opt/klipperscreen/venv/bin/python /opt/klipperscreen/KlipperScreen/screen.py "$@"' >> /opt/klipperscreen/start.sh && \
    echo '  echo "WARNING: KlipperScreen exited with code $?, restarting in ${KLIPPERSCREEN_RESTART_DELAY} seconds..."' >> /opt/klipperscreen/start.sh && \
    echo '  sleep ${KLIPPERSCREEN_RESTART_DELAY}' >> /opt/klipperscreen/start.sh && \
    echo 'done' >> /opt/klipperscreen/start.sh && \
    chmod +x /opt/klipperscreen/start.sh

# Set the custom wrapper script as the default entrypoint
ENTRYPOINT [ "/opt/klipperscreen/start.sh" ]

# Set default command to start KlipperScreen with a configuration file
CMD [ "-c", "/opt/klipperscreen/config/klipperscreen.conf" ]
