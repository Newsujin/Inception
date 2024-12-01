FROM debian:bullseye

# PHP 버전 설정
ARG PHP_VERSION=7.4

# 필요한 패키지 설치 및 캐시 정리
RUN apt-get update && \
    apt-get install -y \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-mysql \
    wget \
    curl \
    mariadb-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# wp-cli 설치
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# WordPress 디렉토리 생성 및 다운로드
WORKDIR /var/www/html
RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    rm latest.tar.gz && \
    chown -R www-data:www-data /var/www/html/wordpress && \
    chmod -R 777 /var/www/html/wordpress

# PHP-FPM 설정 변경 및 디렉토리 생성
RUN sed -i "s/listen =.*/listen = 9000/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    mkdir -p /run/php && \
    chown www-data:www-data /run/php

# WordPress 초기화 스크립트 복사 및 실행 권한 부여
COPY ./tools/init_wordpress.sh /init_wordpress.sh
RUN chmod +x /init_wordpress.sh

# WordPress 초기화 스크립트 실행
ENTRYPOINT [ "/init_wordpress.sh" ]