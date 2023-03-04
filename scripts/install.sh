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

mkdir -p $GAMES_ROOT

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

if ! $(which steamcmd) 2>/dev/null; then
    echo "steamcmd not found! Please install it." >&2
    exit 1
fi

# We need exactly one match. Zero's too few, dunno what to do with more than one hit.
GAMEDB_SEARCH_COUNT=$(grep "$GAME" "$GAMESDB_PATH" | wc -l)
if [ "$GAMEDB_SEARCH_COUNT" != "1" ]; then
    echo "Invalid search query '$GAME', found $GAMEDB_SEARCH_COUNT results" >&2
    exit 1
fi

# Games database lines are formatted as:
# gametitle;alias1;alias2;etc|appid
GAMEDB_APPID=$(grep "$GAME" "$GAMESDB_PATH" | awk '{split($0,a,"|"); print a[1]}')

steamcmd +force_install_dir "$GAMES_ROOT/$GAME" +login "$STEAMUSER" "$STEAMPASSWORD" +app_update "$GAMEDB_APPID" +validate +quit
