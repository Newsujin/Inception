#!/bin/sh

# 볼륨이 마운트된 후, MySQL 데이터 디렉토리의 권한을 설정
# 호스트 시스템의 권한이 컨테이너 내부에서 mysql 사용자가 접근할 수 있도록 설정
chown -R mysql:mysql /var/lib/mysql

# MariaDB 서버를 백그라운드에서 네트워크 없이 시작
# --skip-networking 옵션은 네트워크 연결을 막고 로컬에서만 접근 가능하도록 설정
mysqld_safe --skip-networking --nowatch

# MariaDB 서버가 완전히 시작될 때까지 대기
# mysqladmin ping 명령어를 사용하여 서버가 응답할 때까지 1초 간격으로 확인
while ! mysqladmin ping --silent; do
    sleep 1
done

# 필수 환경변수 확인
# 각 환경변수가 비어 있으면 스크립트를 종료하고 오류 메시지 출력
if [ -z "${MYSQL_ROOT_PASSWORD}" ] || [ -z "${MYSQL_DATABASE}" ] || [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_PASSWORD}" ]; then
    echo "One or more environment variables are not set. Exiting the script..."
    exit 1
fi
# for var in MYSQL_ROOT_PASSWORD MYSQL_DATABASE MYSQL_USER MYSQL_PASSWORD; do
#   if [ -z "${!var}" ]; then
#     echo "Error: $var is not set. Exiting."
#     exit 1
#   fi
# done

# 데이터베이스가 이미 존재하는지 확인
# mysql 명령어를 사용하여 지정된 데이터베이스가 존재하는지 확인
# if ! mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "USE ${MYSQL_DATABASE};" 2>/dev/null; then
#     echo "Initializing database..."

#     # 데이터베이스와 사용자 생성 SQL 작성
#     cat << EOF > /tmp/create_db.sql
# CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci;
# CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
# GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
# FLUSH PRIVILEGES;
# EOF
DB_EXISTS=$(mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SHOW DATABASES LIKE '${MYSQL_DATABASE}';" | grep "${MYSQL_DATABASE}" > /dev/null; echo "$?")

# 데이터베이스가 존재하지 않으면 초기화 스크립트를 실행
if [ $DB_EXISTS -ne 0 ]; then
    # SQL 스크립트를 작성하여 데이터베이스와 사용자를 생성
    cat << EOF > /tmp/create_db.sql
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    # 생성된 SQL 스크립트 파일의 소유자 및 권한 설정
    chown mysql:mysql /tmp/create_db.sql
    chmod 600 /tmp/create_db.sql
    echo ${MYSQL_DATABASE}
    echo ${MYSQL_USER}

    # SQL 스크립트를 실행하여 데이터베이스와 사용자를 생성
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < /tmp/create_db.sql

    # 스크립트 파일 삭제
    rm /tmp/create_db.sql
fi

# MariaDB 서버를 종료하여 초기화 작업 완료 후 종료
mysqladmin shutdown

# 네트워크를 활성화하여 MariaDB 서버를 포그라운드에서 실행
exec mysqld_safe