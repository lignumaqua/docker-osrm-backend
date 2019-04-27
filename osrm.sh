#!/bin/sh

OSRM_DATA_PATH="/data"

_sig() {
  kill -TERM $child 2>/dev/null
}

trap _sig SIGKILL SIGTERM SIGHUP SIGINT EXIT

if [ ! -f $OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm.mldgr ] && [ ! -f $OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm.hsgr ]; then
  if [ ! -f $OSRM_DATA_PATH/$OSRM_MAP_NAME.osm.pbf ]; then
    echo "Downloading $OSRM_MAP_NAME from $OSRM_MAP_URL"
    curl -L $OSRM_MAP_URL --create-dirs -o $OSRM_DATA_PATH/$OSRM_MAP_NAME.osm.pbf 
    reteval=$?
    if [ ${reteval} -ne 0 ]; then
      echo "$OSRM_MAP_NAME download to $OSRM_DATA_PATH/$OSRM_MAP_NAME.osm.pbf failed"
      exit 1;
    fi
    FILESIZE=$(stat -c%s "$OSRM_DATA_PATH/$OSRM_MAP_NAME.osm.pbf")
    echo "$OSRM_MAP_NAME downloaded to $OSRM_DATA_PATH/$OSRM_MAP_NAME.osm.pbf ($FILESIZE bytes)"
  fi
  
  echo "Extracting the Road Network from $OSRM_DATA_PATH/$OSRM_MAP_NAME.osm.pbf using $OSRM_EXT_PROFILE profile"
  osrm-extract -p /opt/$OSRM_EXT_PROFILE.lua $OSRM_DATA_PATH/$OSRM_MAP_NAME.osm.pbf
  reteval=$?
  if [ ${reteval} -ne 0 ]; then
    echo "$OSRM_MAP_NAME extraction to $OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm failed"
    exit 1;
  fi
  FILESIZE=$(stat -c%s "$OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm")
  echo "$OSRM_MAP_NAME extracted to $OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm ($FILESIZE bytes)"
  
  echo "Deleting $OSRM_DATA_PATH/$OSRM_MAP_NAME.osm.pbf"
  rm $OSRM_DATA_PATH/$OSRM_MAP_NAME.osm.pbf
  
  if [ "$OSRM_PIPELINE" == "CH" ]; then
    echo "Contracting $OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm"
    OSRM_API_PARAMS="$OSRM_API_PARAMS --algorithm CH"
    osrm-contract $OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm
    FILESIZE=$(stat -c%s "$OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm.hsgr")
    echo "$OSRM_MAP_NAME hierarchy precomputed using $OSRM_PIPELINE to $OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm.hsgr ($FILESIZE bytes)"
  else
    OSRM_PIPELINE="MLD"
    echo "Creating Hierarchy from $OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm"
    OSRM_API_PARAMS="$OSRM_API_PARAMS --algorithm MLD"
    osrm-partition $OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm
    if [ ${reteval} -ne 0 ]; then
     echo "$OSRM_MAP_NAME hierarchy precomputation to $OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm failed"
      exit 1;
    fi
    osrm-customize $OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm
    FILESIZE=$(stat -c%s "$OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm.mldgr")
    echo "$OSRM_MAP_NAME precomputed using $OSRM_PIPELINE to $OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm.mldgr ($FILESIZE bytes)"
  fi
  echo "$OSRM_MAP_NAME.osm.pbf pre-processing ended"
fi

echo "Starting routing engine HTTP server"
osrm-routed $OSRM_DATA_PATH/$OSRM_MAP_NAME.osrm $OSRM_API_PARAMS &
child=$!
wait "$child"
