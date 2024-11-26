# Debian bullseye 기반 이미지 사용
FROM debian:bullseye

# 필요한 패키지 설치
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nginx openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Nginx 설정 파일 복사
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# init_nginx.sh 파일 복사
COPY ./tools/init_nginx.sh /init_nginx.sh

# init_nginx.sh 실행 권한 부여
RUN chmod +x /init_nginx.sh

# init_nginx.sh 실행
CMD ["/init_nginx.sh"]