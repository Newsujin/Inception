# Inception 🧭

Inception 프로젝트는 `Docker`를 사용하여 `NGINX`, `WordPress`, `php-fpm`, `MariaDB`를 포함한 소규모 인프라를 가상 머신 환경에서 구축하는 시스템 관리 실습입니다.
<br>모든 서비스는 각각의 `Docker 컨테이너`에서 실행되며, `도커 네트워크`를 통해 연결됩니다.
`TLS`를 적용한 NGINX를 진입점으로 설정하고, WordPress와 데이터베이스를 위한 `볼륨`을 구성해야 하며, 환경 변수와 `Docker Compose`를 활용한 자동화를 요구합니다.

# 목차
1. [개요](#개요)
2. [프로젝트 요구 사항](#프로젝트-요구-사항)
3. [디렉터리 구조](#디렉터리-구조)
4. [서비스별 간단 개요](#서비스별-간단-개요)
5. [실행 방법](#실행-방법)
6. [예상 동작 흐름](#예상-동작-흐름)
7. [개념 정리](#개념-정리)


# 개요

### 프로젝트 목표
- Docker를 활용한 시스템 관리 지식을 확장하는 것을 목표로 합니다.

### 핵심 아이디어
- 여러 개의 Docker 이미지를 가상화하여, 개인 가상 머신에서 서로 다른 서비스를 구성합니다.

### 사용 기술
- Docker & Docker Compose
- Nginx (TLS 적용)
- WordPress + PHP-FPM
- MariaDB


# 프로젝트 요구 사항

## 1. 필수 요구 사항
- **Docker Compose 사용**: 각 서비스는 별도의 컨테이너에서 실행하며, `docker-compose.yml`을 통해 전체 인프라를 정의합니다.
- **이미지 빌드**: 각 서비스에 대해 Dockerfile을 작성하여 직접 이미지를 빌드합니다.
- **서비스 구성**:
  - **Nginx**: TLSv1.2/1.3만 지원
  - **WordPress + PHP-FPM**
  - **MariaDB**
  - **볼륨 및 네트워크 설정**
- **환경 변수 관리**: 비밀번호 등 민감 정보는 `.env` 파일로 관리하며, 해당 파일은 Git에 업로드하지 않습니다.
- **컨테이너 재시작 설정**: 충돌(Crash) 시 자동으로 재시작(`restart: always`) 설정

## 2. 금지 사항
- `network: host`, `--link`, `links:` 등 호스트 네트워크 공유
- 무한 루프(`tail -f`, `sleep infinity` 등)로 컨테이너 유지


# 디렉터리 구조

```bash
Inception/
├── Makefile
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── conf/
        │   ├── tools/
        │   └── Dockerfile
        ├── nginx/
        │   ├── conf/
        │   ├── tools/
        │   └── Dockerfile
        └── wordpress/
            ├── conf/
            ├── tools/
            └── Dockerfile
```
- **Makefile**: 프로젝트 전체 빌드 및 실행·종료를 자동화
- **docker-compose.yml**: 컨테이너, 볼륨, 네트워크 정의
- **.env**: 민감 정보 관리 (Git에 업로드하지 않음)
- **requirements**: 각 서비스별 폴더에 필요한 Dockerfile, 설정파일, 초기화 스크립트 포함

# 서비스별 간단 개요

### Nginx (TLS)
- **443(SSL) 포트만** 열어두고, **TLSv1.2/1.3** 적용
- 테스트 환경에서는 **Self-signed 인증서** 사용

### WordPress + PHP-FPM
- `/var/www/html/wordpress` 경로에 **웹사이트 파일** 배치
- **PHP-FPM**을 사용하여 PHP 코드 처리

### MariaDB
- `/var/lib/mysql` 경로에 **DB 파일** 저장
- WordPress용 **DB 생성 및 초기 설정** 수행


# 실행 방법

### 1. .env 파일 설정

`.env` 파일에 민감한 정보를 추가합니다:
```bash
DOMAIN=mylogin.42.fr
MYSQL_ROOT_PASSWORD=secret
MYSQL_USER=wp_user
MYSQL_PASSWORD=wp_password
MYSQL_DATABASE=wordpress_db
```
### 2. 빌드 및 실행 (Makefile 사용)

```bash
# 컨테이너 실행
make

# 컨테이너와 볼륨 정리 (종료 + 제거)
make clean

# 이미지와 캐시까지 강제 제거 등 완전 초기화
make fclean

# 초기화 후 재실행
make re
```
# 예상 동작 흐름
### 1. nginx:
- HTTPS 요청(포트 443)을 수신하여 wordpress로 전달.
### 2. wordpress:
- 콘텐츠 요청을 처리하고, 필요한 경우 mariadb와 통신하여 데이터베이스에서 정보를 가져옴.
### 3. mariadb:
- wordpress에서 요청받은 데이터를 처리하고 반환.

> 이 모든 통신은 inception-network 내에서 이루어지며, 외부로 노출되지 않기 때문에 보안성과 효율성이 높아집니다.

# 개념 정리

## Docker
- **컨테이너 기반 가상화** 기술
- 애플리케이션과 필요한 라이브러리를 **컨테이너**라는 가벼운 단위로 실행
- 컨테이너는 호스트 OS의 커널을 공유하여 애플리케이션을 격리된 환경에서 실행

### Docker의 발생 배경
- 기존 시스템에서는 여러 애플리케이션을 구동하기 위해 다양한 패키지, 환경설정 통일 필요
    - 이런 과정 속에서 **패키지끼리의 충돌이나 환경변수 충돌과 같은 문제가 많이 발생**
- 이러한 문제점을 해결하기 위해 **애플리케이션별로 환경변수와 패키지를 분리해 가상화**시켜 구동하는 `VM(Virtual Machine)`이 나옴
    
    → VM은 `Hypervisor`를 이용해 Guest OS를 생성하기 때문에 **환경 자체가 상당히 무거운 단점**

=> VM의 단점을 보완하기 위해 나온 것이 운영체제 단에서 가상화를 실행하는 `container`이며, container 기술을 편리하게 사용할 수 있도록 개발된 것이 `Docker`이다.

## Docker vs Virtual Machine
![image](https://github.com/user-attachments/assets/44f2442d-11c9-4eee-8958-dcea0064d801)

| 항목            | Docker                                   | Virtual Machine                     |
|----------------|------------------------------------------|-------------------------------------|
| 격리 수준       | 프로세스 수준 격리                        | 하드웨어 수준 격리                  |
| 자원 소비       | 경량, 빠른 실행                           | 무겁고 더 많은 리소스 필요           |
| OS 호환성       | 호스트 OS 커널 계열만 지원                | 다양한 OS 실행 가능                 |
| 주요 사용 사례   | 애플리케이션 배포, 마이크로서비스          | 완전한 OS 환경 및 강력한 격리 필요    |

## Docker Image
- 컨테이너를 실행하기 위한 **템플릿**
- 애플리케이션과 필요한 모든 의존성을 포함한 읽기 전용 파일 시스템
- 계층 구조, 여러 이미지가 부모-자식 관계 이루어질 수 있음
```bash
# 이미지 빌드 명령어
docker build -t <image_name> <Dockerfile_directory>
```

- 예) `FROM debian:bullseye`는 `debian:bullseye` 이미지를 기반으로 새로운 이미지를 생성

**레이어란?**

- Docker 이미지는 명령어마다 하나의 레이어를 생성
- 이전 레이어가 캐시로 저장되어, 변경되지 않은 레이어는 재사용

## Docker Container
- Docker 이미지를 실행한 **가상화된 런타임 환경**
- 실행 중에 데이터 저장 및 변경 가능
- 컨테이너는 이미지로부터 생성되며, 애플리케이션 실행 시 필요한 네트워크 및 스토리지 설정도 포함
```bash
# 컨테이너 생성 및 실행 명령어
docker run -d --name <container_name> <image_name>
```

## Docker Image vs Container

| 항목   | 이미지                                  | 컨테이너                            |
|--------|----------------------------------------|-------------------------------------|
| 목적   | 컨테이너 실행을 위한 템플릿             | 실행 중인 가상화된 애플리케이션 환경 |
| 특징   | 읽기 전용, 불변                         | 실행 중 데이터 변경 가능             |
| 상태   | 저장된 파일 형태                        | 실행 중인 프로세스                  |


## Docker Compose
### 개념

- 여러 컨테이너를 정의하고 함께 관리하기 위한 도구
- `docker-compose.yml` 파일에서 **멀티 컨테이너 애플리케이션**의 설정(서비스, 볼륨, 네트워크 등) 정의
- 예) 데이터베이스와 웹 서버 같은 서비스가 서로 독립적으로 실행되지만, **하나의 네트워크에서 통신 가능**

### 주요 구성 요소
- **services**: 실행할 컨테이너 정의
- **ports**: 호스트와 컨테이너 간의 포트 매핑
- **volumes**: 파일 시스템 공유
- **networks**: 컨테이너 간 통신을 위한 네트워크 정의
- **depends_on**: 서비스 간 종속성 정의

### ports vs volumes

| 항목 | ports | volumes |
| --- | --- | --- |
| 역할 | 네트워크 포트 매핑 (컨테이너 ↔ 호스트) | 파일 시스템 공유 (컨테이너 ↔ 호스트 또는 컨테이너 ↔ 볼륨) |
| 사용 목적 | 컨테이너의 서비스(네트워크 기반)에 외부 접근 가능하게 설정 | 컨테이너 데이터의 영구 저장 또는 데이터 공유 |
| 구문 | “호스트포트:컨테이너포트” | “호스트경로:컨테이너경로[:옵션]” |
| 데이터 지속성 | 없음 (컨테이너 중지 시 네트워크 매핑 만 해제됨) | 있음 (컨테이너 삭제 후에도 호스트의 데이터 유지 가능) |
| 예시 | - “8000:80” | - “./data:/var/lib/mysql” |

### 명령어
```bash
# 컨테이너 시작
docker compose up

# 백그라운드 실행
docker compose up -d

# 컨테이너 중지 및 삭제
docker compose down

# 특정 서비스만 실행
docker compose up <service_name>

# 로그 확인
docker compose logs
```

## Docker Volume

### 개념
도커 컨테이너와 호스트 시스템 간에 데이터를 안전하고 효율적으로 공유하기 위한 메커니즘

### 주요 특징
**데이터 영속성 보장**

- 컨테이너가 삭제되어도 데이터는 삭제되지 않고 유지
- 영구적으로 저장해야 할 데이터(로그, DB 파일, 설정 파일 등) 관리하기에 적합

**컨테이너 간 데이터 공유**

- 여러 컨테이너가 동일한 데이터 공유할 때 도커 볼륨 사용 가능

**호스트 독립성**

- 도커 호스트 운영 체제의 파일 구조와 무관하게 데이터를 독립적으로 관리

**컨테이너 독립성**

- 특정 컨테이너에 종속되지 않고 다른 컨테이너에서도 재사용 가능

## Docker Network

### 개념
Docker 컨테이너 간의 통신을 관리하고 격리하기 위한 도커의 기능

### 주요 기능

1. 컨테이너 간 통신
    - 같은 네트워크에 속한 컨테이너들은 기본적으로 서로 통신 가능
2. 외부 통신 허용
    - 컨테이너가 외부 네트워크(예: 인터넷)와 통신할 수 있도록 지원
3. 네트워크 격리
    - 컨테이너 간 네트워크를 분리하여 보안과 성능 향상
4. DNS 기반 이름 해석
    - 컨테이너 이름을 DNS로 해석해 IP 주소 대신 이름으로 접근 가능

### Docker 네트워크 종류

- **bridge** (기본): 컨테이너 간 통신 가능, 호스트와는 분리된 네트워크
- **host**: 컨테이너가 호스트 네트워크를 공유. 성능은 좋지만 격리가 없음
- **none**: 네트워크를 완전히 비활성화

## Dockerfile

### 주요 명령어
| 명령어       | 설명                                                                 |
|--------------|----------------------------------------------------------------------|
| FROM         | 베이스 이미지 지정 (Dockerfile의 첫 번째 명령어로 시작해야 함)       |
| RUN          | 컨테이너 빌드 중 실행할 명령어 (패키지 설치, 설정 등)                |
| COPY         | 로컬 파일을 컨테이너 내부로 복사                                     |
| ADD          | COPY와 유사하나, URL에서 파일 다운로드 및 압축 해제 기능 추가        |
| CMD          | 컨테이너 시작 시 실행할 명령어 (단 하나만 사용 가능)                 |
| ENTRYPOINT   | 컨테이너 실행 시 고정 명령어를 설정                                  |
| ENV          | 환경 변수 설정                                                      |
| WORKDIR      | 컨테이너 작업 디렉토리 지정 (RUN, CMD 등이 여기서 실행됨)            |

### ENTRYPOINT vs CMD

| 항목          | CMD                                        | ENTRYPOINT                                   |
|---------------|-------------------------------------------|---------------------------------------------|
| 목적          | 컨테이너 실행 시 기본 명령어 설정          | 고정 명령어 설정 후 추가 인자를 받을 수 있음|
| 유연성        | 단순한 명령어 실행에 적합                 | 명령어를 고정하고 추가 인자 전달 가능       |

**결합 사용 예시**:
```bash
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
```
- docker run 시 CMD는 ENTRYPOINT의 기본 인자처럼 동작.

### 효율적인 Dockerfile 작성법 (빌드 캐시 최적화)
- 자주 변경되는 명령어는 Dockerfile **하단에 작성** (캐시 활용)
- 불필요한 파일을 제거하여 Docker 이미지 크기 최소화
- 멀티라인 명령어를 사용하여 빌드 단계 최소화:
    ```bash
    RUN apt-get update && \
        apt-get install -y curl wget && \
        apt-get clean && rm -rf /var/lib/apt/lists/*
    ```

## NGINX

### 개념
웹 서버, 리버스 프록시, 로드 밸런서 등 다방면으로 활용 가능한 고성능 오픈소스 소프트웨어

### 역할
1. 클라이언트로부터 요청을 받았을 때 요청에 맞는 **정적 파일을 응답**해주는 `HTTP Web Server`로 활용
2. `Reverse Proxy Server`로 활용하여 WAS 서버의 부하를 줄일 수 있는 **로드 밸런서**로 활용

### 설정
1.	**TLSv1.2/1.3 설정**: nginx.conf의 ssl_protocols 지시자에서 확인할 수 있음.
2.	**nginx.conf 작성**: Dockerfile에서 COPY ./conf/nginx.conf /etc/nginx/nginx.conf로 복사, 실제 설정은 server { listen 443 ssl; ... } 등을 통해 443 포트만 사용함.
3.	**SSL 인증서 생성**: init_nginx.sh 스크립트에서 OpenSSL을 통해 RSA 키와 인증서를 /etc/nginx/ssl 경로에 생성하고, nginx.conf에서 해당 파일 경로를 참조.
4.	**443 포트만 접속**: server { listen 443 ssl; }에 의해 HTTP 80번 포트가 아닌 **443번 포트**로만 연결 가능.

**웹서버란?**

- HTTP 프로토콜을 기반으로 클라이언트가 웹 브라우저에서 어떠한 요청을 하면 그 요청을 받아 정적 컨텐츠를 제공하는 서버

## MariaDB

### 개념
오픈 소스 관계형 데이터베이스 관리 시스템(RDBMS)
- 관계형 데이터베이스란?
    
    데이터를 행과 열로 구성하는 데이터베이스 유형으로, 데이터 포인트가 서로 관련된 테이블을 집합적으로 형성
    
    **관계형(SQL) vs 비관계형(NoSQL)**
    
    | 특징 | RDBS | NoSQL |
    | --- | --- | --- |
    | 데이터 구조 | 테이블 형태 | 키-값, 문서, 그래프, 칼럼 등 다양한 구조 |
    | 스키마 | 고정 스키마 (엄격) | 유연하거나 스키마 없음 |
    | 확장성 | 수직적 확장 (Scale-up) | 수평적 확장 (Scale-out) |
    | 트랜잭션 | ACID 지원 | 일부 NoSQL만 제한적으로 지원 |
    | 쿼리 언어 | SQL 표준 | 고유 쿼리 언어 사용 |
    | 적합한 데이터 | 정형 데이터 (Structured Data) | 비정형 데이터 (Unstructured Data) |
    | 속도 | 소규모 트랜잭션에서 빠름 | 대규모 데이터 읽기/쓰기에서 빠름 |
    | 사용 사례 | 금융, ERP, 회계 시스템 | IoT, 소셜 미디어, 실시간 애플리케이션 |
- Mysql의 포크(Fork)
- MySQL과 호환성을 유지하며 MySQL의 대안으로 널리 사용

### MySQL vs MariaDB

| 특징 | MariaDB | MySQL |
| --- | --- | --- |
| 라이선스 | GNU GPL | GPL, 일부 상업적 라이선스 |
| 스토리지 엔진 | Aria, XtraDB, MyRocks 등 | InnoDB 기본 |
| 개발 속도 | 빠름 | Oracle 정책에 따라 느릴 수 있음 |
| 커뮤니티 지원 | 활발한 오픈 소스 커뮤니티 | Oracle 중심 |
| 성능 최적화 | 새로운 최적화 기능이 많이 추가됨 | 제한적 |

## WordPress

### 개념
- 오픈 소스 콘텐츠 관리 시스템(Content Management System, CMS)

### 특징
- 웹사이트나 블로그를 쉽게 구축 및 관리할 수 있도록 설계됨
- PHP 언어와 MySQL/MariaDB를 기반으로 함
- 누구나 무료로 사용 가능한 GNU GPL 라이선스를 따름

### PHP-FPM
![image](https://github.com/user-attachments/assets/400be44a-a608-4428-ac47-2a9e7dc4a7a4)
PHP FastCGI Process Manager의 약자로, PHP를 실행하기 위한 고성능 FastCGI 관리 프로그램

### PHP
- 서버 측에서 실행되는 스크립트 언어
- 주로 **동적**인 웹 페이지와 애플리케이션을 개발하기 위해 사용

### FastCGI
- CGI(Common Gateway Interface)의 확장으로, **웹 서버와 애플리케이션 간의 고속 통신을 가능하게 하는 프로토콜**
- CGI의 성능 병목을 해결하기 위해 설계

### CGI
![image](https://github.com/user-attachments/assets/9f0c5d10-7028-49c0-b8f7-ec0bd21caba7)
웹 서버가 클라이언트 요청을 처리하기 위해 외부 프로그램을 실행할 수 있도록 연결하는 표준 인터페이스 (프로토콜)


## PID 1 프로세스 관리

- **문제점**: Docker 컨테이너에서 PID 1은 좀비 프로세스를 자동으로 관리
하지 못함.
- **해결 방법**:
  1. **`init: true` 옵션 사용**:
     - Docker Compose에서 `init: true`를 추가하여 경량 init 프로세스(`tini` 등)를 사용.
  2. **포그라운드 실행**:
     - 애플리케이션(예: Nginx)을 데몬 모드 대신 **포그라운드 모드**로 실행.
     - 예: Nginx의 경우 `daemon off;` 옵션 사용.
        ```bash
        CMD ["nginx", "-g", "daemon off;"]
        ```
