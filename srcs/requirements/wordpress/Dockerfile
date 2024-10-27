# WordPress + PHP-FPM + wp-cli Dockerfile
FROM debian:bullseye


ARG VERSION=7.4
# 필요한 패키지 설치
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
php${VERSION}-fpm \
php${VERSION}-mysql \
php-mbstring \
php-xml \
php-json \
wget \
curl \
unzip \
mariadb-client \
&& apt-get clean

COPY ./tools/setup_wordpress.sh /setup_wordpress.sh

# COPY ./conf/www.conf /etc/php8/php-fpm.d/www.conf

# wp-cli 설치
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /bin/wp

WORKDIR /var/www/html/

# WordPress 설치
RUN mkdir -p /var/www/html/ && \
    wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    rm latest.tar.gz && \
    chmod 755 /var/www/html/wordpress
    # chmod 755 /var/www/html/

    # WordPress 파일 소유자 및 권한 설정
RUN chown -R www-data:www-data /var/www/html/wordpress && \
    chmod -R 755 /var/www/html/wordpress
# RUN chown -R www-data:www-data /var/www/html/ && \
#     chmod -R 755 /var/www/html/

    # PHP-FPM 설정 변경 (www.conf)
RUN sed -i "s/listen =.*/listen = 9000/" /etc/php/${VERSION}/fpm/pool.d/www.conf
    
    # PHP-FPM 실행을 위한 디렉토리 생성
RUN mkdir -p /run/php && \
    chown www-data:www-data /run/php && \
    # WordPress 설정 파일 자동화 스크립트 복사
    chmod +x /setup_wordpress.sh

WORKDIR /var/www/html/wordpress

ENTRYPOINT [ "/setup_wordpress.sh" ]