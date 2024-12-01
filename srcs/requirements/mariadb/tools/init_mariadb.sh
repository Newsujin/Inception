#!/bin/sh

# MySQL 데이터 디렉토리를 컨테이너 내부 mysql 사용자가 접근 가능하도록 권한 설정
chown -R mysql:mysql /var/lib/mysql

# MariaDB 서버를 백그라운드에서 네트워크 없이 시작
mysqld_safe --skip-networking --nowatch

# MariaDB 서버가 응답할 때까지 1초 간격으로 대기
while ! mysqladmin ping --silent; do
    sleep 1
done

# 필수 환경 변수 확인
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

# MariaDB 초기화 작업 완료 후 서버 종료
mysqladmin shutdown

# MariaDB 서버 실행 (네트워크 활성화)
exec mysqld_safe