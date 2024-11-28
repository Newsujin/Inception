#!/bin/sh

# 볼륨이 마운트된 후, MySQL 데이터 디렉토리의 권한을 설정
# 호스트 시스템의 권한이 컨테이너 내부에서 mysql 사용자가 접근할 수 있도록 설정
chown -R mysql:mysql /var/lib/mysql

# MariaDB 서버를 백그라운드에서 네트워크 없이 시작
mysqld_safe --skip-networking --nowatch

# MariaDB 서버가 완전히 시작될 때까지 대기
# mysqladmin ping 명령어를 사용하여 서버가 응답할 때까지 1초 간격으로 확인
while ! mysqladmin ping --silent; do
    sleep 1
done

# 필수 환경변수 확인
for var in MYSQL_ROOT_PASSWORD MYSQL_DATABASE MYSQL_USER MYSQL_PASSWORD; do
    if [ -z "$(eval echo \$$var)" ]; then
        echo "Error: $var is not set. Exiting."
        exit 1
    fi
done

# 데이터베이스 존재 여부 확인
if ! mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SHOW DATABASES LIKE '${MYSQL_DATABASE}';" | grep -q "${MYSQL_DATABASE}"; then
    echo "Initializing database: ${MYSQL_DATABASE}"

    # 데이터베이스 및 사용자 생성
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo "Database ${MYSQL_DATABASE} and user ${MYSQL_USER} initialized."
else
    echo "Database ${MYSQL_DATABASE} already exists. Skipping initialization."
fi

# MariaDB 서버를 종료하여 초기화 작업 완료 후 종료
mysqladmin shutdown

# 네트워크를 활성화하여 MariaDB 서버를 포그라운드에서 실행
exec mysqld_safe