#!/bin/bash
# WordPress 설정 파일 자동화 스크립트 (setup_wordpress.sh)

# MariaDB 서버와 연결을 시도하여 WordPress 데이터베이스가 생성될 때까지 대기
# MariaDB 서버가 실행되고 mydatabase 데이터베이스가 생성될 때까지 반복해서 확인
until mysql -h"mariadb" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES;" 2> ./error.log | grep -q "$MYSQL_DATABASE"; do
  echo "Waiting for WordPress database creation..."
  sleep 3
done

# WordPress 설치 디렉토리로 이동
cd /var/www/html/wordpress/

# WordPress 설정 파일이 존재하지 않는 경우 설정 파일 생성
if [ ! -f "/var/www/html/wordpress/wp-config.php" ]; then
  
  # wp-cli를 사용하여 wp-config.php 파일 생성
  wp config create \
    --allow-root \
    --dbname=$MYSQL_DATABASE \
    --dbuser=$MYSQL_USER \
    --dbpass=$MYSQL_PASSWORD \
    --dbhost=$WORDPRESS_DB_HOST \
    --path=/var/www/html/wordpress \
    --skip-check
fi

# WordPress를 설치
wp core install \
  --allow-root \
  --url=$DOMAIN \
  --title=$TITLE \
  --admin_user=$WORDPRESS_ADMIN_USER \
  --admin_password=$WORDPRESS_ADMIN_PASSWORD \
  --admin_email=$WORDPRESS_ADMIN_EMAIL \
  --locale=ko_KR

# 추가 사용자 생성
wp user create $WORDPRESS_USER $WORDPRESS_USER_EMAIL --user_pass=$WORDPRESS_USER_PASSWORD --allow-root

# PHP-FPM을 포그라운드에서 실행
exec php-fpm7.4 -F