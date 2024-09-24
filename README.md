# Inception 🧭

## 개요
이 프로젝트는 Docker를 활용한 시스템 관리 지식을 확장하는 것을 목표로 합니다. 여러 Docker 이미지를 가상화하여 개인 가상 머신에서 다양한 서비스를 설정하게 됩니다.

## 프로젝트 요구 사항

### 필수 요구 사항
1. **Docker Compose 사용**: 프로젝트는 Docker Compose를 사용하여 구성되며, 각 서비스는 별도의 컨테이너에서 실행됩니다.
2. **이미지 빌드**: 각 서비스에 대한 Docker 이미지를 직접 작성해야 하며, 사전에 빌드된 이미지를 사용하는 것은 금지됩니다 (Alpine/Debian 제외).
3. **서비스 구성**:
   - NGINX 컨테이너 (TLSv1.2 또는 TLSv1.3만 지원)
   - WordPress + php-fpm 컨테이너 (NGINX는 제외)
   - MariaDB 컨테이너 (NGINX는 제외)
   - WordPress 데이터베이스를 저장하는 볼륨
   - WordPress 웹사이트 파일을 저장하는 두 번째 볼륨
   - 각 컨테이너를 연결하는 도커 네트워크
4. **컨테이너 재시작**: 컨테이너가 충돌 시 자동으로 재시작되도록 설정해야 합니다.
5. **사용자 구성**: WordPress 데이터베이스에는 관리자 권한을 가진 사용자와 일반 사용자가 있어야 합니다. 관리자 이름에 "admin" 또는 "administrator"는 포함될 수 없습니다.
6. **도메인 설정**: 도메인은 `login.42.fr` 형식이어야 하며, 본인의 로그인 ID를 사용하여 설정해야 합니다.
7. **환경 변수**: Dockerfile에 비밀번호는 포함될 수 없으며, 모든 민감한 정보는 `.env` 파일에 저장하고 Git에 업로드하지 않도록 주의해야 합니다.

### 금지 사항
- `network: host`, `--link`, 또는 `links:` 사용 금지
- 컨테이너 시작 시 무한 루프 실행 금지 (예: `tail -f`, `sleep infinity`, `while true` 등)

### 디렉터리 구조 예시
```bash
$> ls -alR
total XX
drwxrwxr-x 3 user user 4096 2023-09-24 20:42 .
drwxrwxrwt 17 user user 4096 2023-09-24 20:42 ..
-rw-rw-r-- 1 user user XXXX 2023-09-24 20:42 Makefile
drwxrwxr-x 3 user user 4096 2023-09-24 20:42 srcs

./srcs:
total XX
drwxrwxr-x 3 user user 4096 2023-09-24 20:42 .
drwxrwxr-x 3 user user 4096 2023-09-24 20:42 ..
-rw-rw-r-- 1 user user XXXX 2023-09-24 20:42 docker-compose.yml
-rw-rw-r-- 1 user user XXXX 2023-09-24 20:42 .env
drwxrwxr-x 5 user user 4096 2023-09-24 20:42 requirements
