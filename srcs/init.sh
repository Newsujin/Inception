#!/bin/sh

ENV_FILE="srcs/.env"

# 플랫폼에 따른 경로 설정
if [ "$(uname)" == "Darwin" ]; then
    # macOS
    BASE_DIR="$HOME/data"
else
    # Linux
    BASE_DIR="/home/$USER/data"
fi

# 볼륨 삭제
if [ "$1" == "--delete" ]; then
    echo "Deleting volume..."
    rm -rf "$BASE_DIR"
    echo "Delete COMPLETE"

    if [ -f "$ENV_FILE" ]; then
        sed -i '' '/^DATA_PATH=/d' "$ENV_FILE"
        echo "Removed DATA_PATH from .env file."
    else
        echo ".env file not found. Skipping DATA_PATH removal."
    fi
    exit 0
fi

# 볼륨 디렉토리 생성
if [ ! -d "$BASE_DIR" ]; then
    echo "Creating volumes..."
	mkdir -p $BASE_DIR/wordpress/
	mkdir -p $BASE_DIR/mariadb/
    echo "Volumes created in $BASE_DIR"
fi

# .env 파일에 데이터 경로 추가
if ! grep -q "^DATA_PATH=" "$ENV_FILE"; then
    echo "" >> "$ENV_FILE"
    echo "DATA_PATH=$BASE_DIR" >> "$ENV_FILE"
    echo "DATA_PATH added to .env"
fi