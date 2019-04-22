FROM osrm/osrm-backend:latest
MAINTAINER Simone Primarosa <info@simoneprimarosa.com>
# Edited by Mike Wood to use MLD toolchain

RUN mkdir /data
VOLUME ["/data"]

COPY osrm.sh .

# Show current folder structure in logs
RUN ls /data -al -R
RUN ls /src -al -R

# Start a routing engine HTTP server
CMD ./osrm.sh
