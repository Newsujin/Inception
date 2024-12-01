#!/bin/sh

# 필수 환경 변수 확인
REQUIRED_VARS="DOMAIN WORDPRESS_DB_HOST WORDPRESS_TITLE WORDPRESS_ADMIN_USER WORDPRESS_ADMIN_PASSWORD WORDPRESS_ADMIN_EMAIL WORDPRESS_USER WORDPRESS_USER_EMAIL WORDPRESS_USER_PASSWORD"

for var in $REQUIRED_VARS; do
    if [ -z "$(eval echo \$$var)" ]; then
        echo "Error: $var is not set. Exiting."
        exit 1
    fi
done

# # WordPress 데이터베이스 생성 대기 (3초 간격으로 MariaDB 연결 시도)
until mysql -h"$WORDPRESS_DB_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES;" 2> ./error.log | grep -q "$MYSQL_DATABASE"; do
  echo "Waiting for WordPress database creation..."
  sleep 3
done

# WordPress 설정 파일 생성 (wp-config.php)
cd /var/www/html/wordpress/
if [ ! -f "wp-config.php" ]; then
  wp config create \
    --allow-root \
    --dbname=$MYSQL_DATABASE \
    --dbuser=$MYSQL_USER \
    --dbpass=$MYSQL_PASSWORD \
    --dbhost=$WORDPRESS_DB_HOST \
    --skip-check
fi

# WordPress를 설치
if ! wp core is-installed --allow-root; then
  wp core install \
    --allow-root \
    --url=$DOMAIN \
    --title=$WORDPRESS_TITLE \
    --admin_user=$WORDPRESS_ADMIN_USER \
    --admin_password=$WORDPRESS_ADMIN_PASSWORD \
    --admin_email=$WORDPRESS_ADMIN_EMAIL \
    --locale=ko_KR
fi

# 추가 사용자 생성
if ! wp user get "$WORDPRESS_USER" --allow-root > /dev/null 2>&1; then
  wp user create \
    $WORDPRESS_USER \
    $WORDPRESS_USER_EMAIL \
    --user_pass=$WORDPRESS_USER_PASSWORD \
    --allow-root
fi

# PHP-FPM을 포그라운드에서 실행
exec php-fpm7.4 -F