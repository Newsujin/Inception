#!/bin/bash

ENV_FILE="srcs/.env"


if [ "$(uname)" == "Darwin" ]; then
    # macOS
    BASE_DIR="/Users/sujin/data"
    # BASE_DIR="/Users/$USER/data"
else
    # Linux
    BASE_DIR="/home/$USER/data" # spark2 대신 root로 설정될 수 있으니 hard-coding 고려
fi

if [ "$1" == "--delete" ]; then
    echo "Deleting volume..."
    rm -rf "$BASE_DIR"
    echo "Delete COMPLETE"

    if [ -f "$ENV_FILE" ]; then
        sed -i '' '/^DATA_PATH=/d' "$ENV_FILE"
    else
        echo ".env file not found. Skipping DATA_PATH removal."
    fi
    exit 0
fi

if [ ! -d "$BASE_DIR" ]; then
    echo "Add volumes..."
	mkdir -p $BASE_DIR/wordpress/
	mkdir -p $BASE_DIR/mariadb/
    echo "Add COMPLETE"
fi

if ! grep -q "DATA_PATH=" srcs/.env; then
	if [ -s srcs/.env ] && [ "$(tail -c 1 srcs/.env | wc -l)" -eq 0 ]; then
    echo "" >> srcs/.env
	fi
    echo "DATA_PATH=$BASE_DIR" >> srcs/.env
fi