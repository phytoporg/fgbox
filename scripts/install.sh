#!/usr/bin/bash

################################################################################
# install.sh - Installs a game using steamcmd
################################################################################

GAMESDB_PATH=$HOME/data/gamesdb
GAMES_ROOT=$HOME/games
STEAMUSER=
STEAMPASSWORD=
GAME=

while (( "$#" )); do
    if [[ "$1" == "--games-db" ]]; then
        shift
        GAMESDB_PATH=$1
    elif [[ "$1" == "--games-root" ]]; then
        shift
        GAMES_ROOT=$1
    elif [[ "$1" == "--steamuser" ]]; then
        shift
        STEAMUSER=$1
    elif [[ "$1" == "--steampassword" ]]; then
        shift
        STEAMPASSWORD=$1
    elif [[ "$1" == "--game" ]]; then
        shift
        GAME=$1
    fi

    shift
done

mkdir -p "$GAMES_ROOT"

if [ ! -f "$GAMESDB_PATH" ]; then
    echo "Invalid or missing games database file: $GAMESDB_PATH" >&2
    exit 1
fi

if [ "$STEAMUSER" == "" ]; then
    echo "Steam username is required" >&2
    exit 1
fi

if [ "$STEAMPASSWORD" == "" ]; then
    echo "Steam password is required" >&2
    exit 1
fi

if [ "$GAME" = "" ]; then
    echo "Game is required" >&2
    exit 1
fi

if ! which steamcmd 2>/dev/null; then
    echo "steamcmd not found! Please install it." >&2
    exit 1
fi

# We need exactly one match. Zero's too few, dunno what to do with more than one hit.
GAMEDB_SEARCH_COUNT=$(grep -c "$GAME" "$GAMESDB_PATH")
if [ "$GAMEDB_SEARCH_COUNT" != "1" ]; then
    echo "Invalid search query '$GAME', found $GAMEDB_SEARCH_COUNT results" >&2
    exit 1
fi

# Games database lines are formatted as:
# gametitle;alias1;alias2;etc|appid
GAMEDB_RESULT=$(grep "$GAME" "$GAMESDB_PATH")
GAMEDB_APPID=$(echo "$GAMEDB_RESULT" | awk '{split($0,a,"|"); print a[2]}')
GAMEDB_APPNAME=$(echo "$GAMEDB_RESULT" | awk '{split($0,a,";"); print a[1]}')
INSTALL_PATH=$GAMES_ROOT/$GAME

echo "Installing '$GAMEDB_APPNAME' to '$INSTALL_PATH'..."

# Generate a script and run it via steamcmd
STEAMCMD_SCRIPT_PATH=$(mktemp)

echo "@ShutdownOnfailedCommand 1" > "$STEAMCMD_SCRIPT_PATH"
echo "@NoPromptForPassword 1" >> "$STEAMCMD_SCRIPT_PATH"
echo "@sSteamCmdForcePlatformType windows" >> "$STEAMCMD_SCRIPT_PATH"
echo "force_install_dir $INSTALL_PATH" >> "$STEAMCMD_SCRIPT_PATH"
echo "login $STEAMUSER $STEAMPASSWORD" >> "$STEAMCMD_SCRIPT_PATH"
echo "app_update $GAMEDB_APPID validate" >> "$STEAMCMD_SCRIPT_PATH"
echo "quit" >> "$STEAMCMD_SCRIPT_PATH"

steamcmd +runscript "$STEAMCMD_SCRIPT_PATH"
rm "$STEAMCMD_SCRIPT_PATH"
