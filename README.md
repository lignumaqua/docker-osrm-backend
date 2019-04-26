# docker-osrm-backend
> 🛣 The Open Source Routing Machine Docker ready!

# Forked from simonepri/docker-osrm-backend

This image is based on the official [osrm-backend](https://hub.docker.com/r/osrm/osrm-backend/) Docker image with the addition of some awesome features!

## Features
* Download and precomputes maps on startup only if it's necessary.
* Configurable with ENV variables.

## Configuration
You need to specify those env vars in order to make the startup process successfully.

 Name | Description
------|-------------
**OSRM_MAP_NAME** | The name of the maps you want to download used as filename.
**OSRM_MAP_URL** | The URL from where the map file will be downloaded. Check [Geofabrik](http://download.geofabrik.de/) for download URLs.
**OSRM_EXT_PROFILE** | The profile to use to extract the road network. See [profiles](https://github.com/Project-OSRM/osrm-backend/wiki/Profiles) for more info about them.
**OSRM_API_PARAMS** | Custom flags to pass to the osrm-routed command. The list of flags is available [here](https://github.com/Project-OSRM/osrm-backend/blob/8aa93f32ccd02ed3cdde2429715cdc9366be87f3/features/options/routed/help.feature#L10)
**OSRM_PIPELINE** | The OSRM pipeline you want to use, MLD or CH. Defaults to MLD.

## Usage
Example of usage.

```bash
$ docker pull lignumaqua/osrm-backend
$ docker run -d -p 5000:5000 --name osrm-api -e OSRM_MAP_NAME="center-italy" -e OSRM_MAP_URL="http://download.geofabrik.de/europe/italy/centro-latest.osm.pbf" -e OSRM_EXT_PROFILE="car" -e OSRM_API_PARAMS="--port 5000" lignumaqua/osrm-backend:latest
OSRM_PIPELINE="MLD" lignumaqua/osrm-backend:latest
```

Also recommended to map the docker /data folder to persistent storage outside the docker using the -v directive.

## Updates by Lignumaqua

1. Added Curl to Docker file. Not present in OSRM Source Docker.
2. Changed sh file to use Curl rather than wget.
3. On startup checks for existence of either .osrm.hsgr from osrm.contract or osrm.mldgr from osrm.customize before downloading and extracting a new osm file. 
4. Option thrugth env variable to choose MLD or CH toolchain
