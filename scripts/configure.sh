#!/usr/bin/bash

################################################################################
# configure.sh - Configures an installed steam game
# 
# Usage: ./configure.sh
#     TODO
################################################################################

APP_ID=
PROTON=

while (( "$#" )); do
    if [[ "$1" == "--app-id" ]]; then
        shift
        APP_ID=$1
    elif [[ "$1" == "--proton" ]]; then
        PROTON=1
    fi

    shift
done

USERCONFIG_PATH=$(ls ~/.steam/steam/userdata)
#TODO: Sanity check USERCONFIG_PATH

LOCAL_VDF_PATH="$USERCONFIG_PATH/config/localconfig.vdf"
#TODO: Sanity check LOCAL_VDF_PATH

TEMP_VDF_OUT=$(mktemp).vdf
NOW=$(date +"%s")
./patch_vdf.py \
    --vdf-file "$LOCAL_VDF_PATH" \
    --data-path "UserLocalConfigStore.Software.Valve.Steam.apps.$APP_ID" \
    --data-value "{ \
        \"LaunchOptions\" : \"PROTON_NO_ESYNC=1 %command%\", \
        \"ViewedLaunchEULA\" : \"1\", \
        \"ViewedSteamPlay\" : \"1\", \
        \"LastPlayed\" : \"$NOW\" \ }" \
        > "$TEMP_VDF_OUT"
