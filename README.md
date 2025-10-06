# Simple WordPress Blog with Docker

이 프로젝트는 Docker를 사용하여 WordPress 블로그를 쉽게 실행할 수 있도록 구성된 프로젝트입니다.

## 구성 요소

- **WordPress**: 최신 WordPress 이미지
- **Twenty Twelve 테마**: 커스텀 테마 포함
- **외부 데이터베이스**: CloudType 데이터베이스 사용

## 사전 요구사항

- Docker

## 설치 및 실행

### 1. 프로젝트 클론 또는 다운로드
```bash
# 프로젝트 디렉토리로 이동
cd C:\projects\simple_blog
```

### 2. Docker 컨테이너 실행

#### Windows에서 실행:
```bash
# 실행 스크립트 사용
run.bat

# 또는 수동으로 실행
docker build -t my-wordpress-blog .
docker run -d --name wordpress-blog -p 8091:80 \
  -e WORDPRESS_DB_HOST=svc.sel4.cloudtype.app:30333 \
  -e WORDPRESS_DB_NAME=blog4 \
  -e WORDPRESS_DB_USER=rmsals \
  -e WORDPRESS_DB_PASSWORD=1q2w3e \
  my-wordpress-blog
```

### 3. 워드프레스 설정
1. 웹 브라우저에서 `http://localhost:8091` 접속
2. 워드프레스 설치 마법사가 나타납니다
3. 다음 정보로 설정:
   - 사이트 제목: 원하는 블로그 제목
   - 사용자명: 관리자 계정
   - 비밀번호: 강력한 비밀번호
   - 이메일: 관리자 이메일

### 4. 테마 활성화
설치 완료 후:
1. **관리자 대시보드** → **외모** → **테마**로 이동
2. **Twenty Twelve** 테마를 찾아서 **활성화** 클릭

## 서비스 중지

```bash
# Windows에서 중지
stop.bat

# 또는 수동으로 중지
docker stop wordpress-blog
docker rm wordpress-blog
```

## 포트 정보

- **WordPress**: http://localhost:8091
- **외부 데이터베이스**: svc.sel4.cloudtype.app:30333

## 데이터 백업

WordPress 데이터는 Docker 볼륨에 저장됩니다:

```bash
# 볼륨 목록 확인
docker volume ls

# 볼륨 백업 (예시)
docker run --rm -v simple_blog_wordpress_data:/data -v $(pwd):/backup alpine tar czf /backup/wordpress-backup.tar.gz -C /data .
```

## 문제 해결

### 포트 충돌
8091 또는 8090 포트가 이미 사용 중인 경우, `docker-compose.yml`에서 포트를 변경하세요:

```yaml
ports:
  - "8092:80"  # 8091 대신 8092 사용
```

### 컨테이너 재시작
```bash
# 특정 서비스 재시작
docker-compose restart wordpress

# 모든 서비스 재시작
docker-compose restart
```

### 로그 확인
```bash
# 모든 서비스 로그
docker-compose logs

# 특정 서비스 로그
docker-compose logs wordpress
docker-compose logs db
```

## 보안 고려사항

- 프로덕션 환경에서는 `.env` 파일의 비밀번호를 강력하게 설정하세요
- `wp-config.php`의 보안 키를 실제 값으로 변경하세요
- 방화벽 설정을 통해 불필요한 포트를 차단하세요

## 추가 기능

### SSL 인증서 설정
프로덕션 환경에서는 Let's Encrypt와 함께 nginx-proxy를 사용하여 SSL을 설정할 수 있습니다.

### 플러그인 및 테마
WordPress 관리자 페이지에서 플러그인과 테마를 설치할 수 있습니다. 설치된 플러그인과 테마는 Docker 볼륨에 저장됩니다.

## 지원

문제가 발생하면 다음을 확인하세요:
1. Docker가 실행 중인지 확인
2. 포트가 사용 가능한지 확인
3. 컨테이너 로그 확인
4. `.env` 파일 설정 확인