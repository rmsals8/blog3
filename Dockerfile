FROM wordpress:latest

# 시스템 업데이트 및 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 테마 복사 (엔트리포인트가 코어를 복사할 때 함께 적용되도록 소스 위치에 배치)
COPY twentytwelve/ /usr/src/wordpress/wp-content/themes/twentytwelve/

# wp-config.php 복사 (엔트리포인트가 코어를 복사할 때 함께 적용되도록 소스 위치에도 둔다)
COPY wp-config.php /usr/src/wordpress/wp-config.php

# Apache 설정 수정 (CloudType.io용)
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf

# Apache 모듈/접근 설정
RUN a2enmod rewrite && \
    printf "<Directory /var/www/html>\n\tOptions FollowSymLinks\n\tAllowOverride All\n\tRequire all granted\n</Directory>\n" > /etc/apache2/conf-available/wordpress.conf && \
    a2enconf wordpress && \
    printf "ServerName localhost\n" > /etc/apache2/conf-available/servername.conf && \
    a2enconf servername

# DirectoryIndex 설정으로 index.php 우선 제공
RUN printf "DirectoryIndex index.php index.html\n" > /etc/apache2/conf-available/dirindex.conf && a2enconf dirindex

# 권한 설정 (Apache 설정 후에 실행)
RUN chown -R www-data:www-data /var/www/html/
RUN find /var/www/html -type d -exec chmod 755 {} +
RUN find /var/www/html -type f -exec chmod 644 {} +
## wp-config.php는 런타임에 배치될 수 있으므로 하드 퍼미션 변경은 생략

# 포트 노출
EXPOSE 8080

# WordPress 시작 (기본 엔트리포인트를 사용하되, index.php가 없을 경우 자동 복사됨)
CMD ["apache2-foreground"]
