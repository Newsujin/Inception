FROM debian:bullseye

# 필요한 패키지 설치
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nginx openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Nginx 설정 파일 복사
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# Nginx 초기화 스크립트 복사 및 실행 권한 부여
COPY ./tools/init_nginx.sh /init_nginx.sh
RUN chmod +x /init_nginx.sh

# Nginx 초기화 스크립트 실행
ENTRYPOINT [ "/init_nginx.sh" ]