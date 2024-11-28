#!/bin/bash

ENV_FILE="srcs/.env"

# 플랫폼에 따른 경로 설정
if [ "$(uname)" == "Darwin" ]; then
    BASE_DIR="$HOME/data" # macOS
else
    BASE_DIR="/home/$USER/data" # Linux
fi

# 볼륨 삭제
if [ "$1" == "--delete" ]; then
    sudo chmod -R 777 $BASE_DIR
    rm -rf "$BASE_DIR"
    echo "Volumes deleted."

    # .env 파일에서 DATA_PATH 제거
    if [ -f "$ENV_FILE" ]; then
        sed -i '/^DATA_PATH=/d' "$ENV_FILE"
        echo "Removed DATA_PATH from .env file."
    else
        echo ".env file not found. Skipping DATA_PATH removal."
    fi
    exit 0
fi

# 볼륨 디렉토리 생성
if [ ! -d "$BASE_DIR" ]; then
    mkdir -p $BASE_DIR/wordpress/
    mkdir -p $BASE_DIR/mariadb/
    chown -R $USER:$USER $BASE_DIR
    chmod -R 777 $BASE_DIR
    echo "Volumes created."
fi

# .env 파일에 데이터 경로 추가
if ! grep -q "^DATA_PATH=" "$ENV_FILE"; then
    echo "DATA_PATH=$BASE_DIR" >> "$ENV_FILE"
    echo "DATA_PATH added to .env file."
fi