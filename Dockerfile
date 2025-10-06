FROM wordpress:latest

# 시스템 업데이트 및 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 워드프레스 코어를 새 위치로 복사
RUN rm -rf /var/www/wordpress && \
    mkdir -p /var/www/wordpress && \
    cp -a /usr/src/wordpress/. /var/www/wordpress/

# 테마 복사
COPY twentytwelve/ /var/www/wordpress/wp-content/themes/twentytwelve/

# wp-config.php 복사
COPY wp-config.php /var/www/wordpress/wp-config.php

# Apache 설정 수정 (CloudType.io용 포트 8080)
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/wordpress#' /etc/apache2/sites-available/000-default.conf

# Apache 디렉토리 설정
RUN printf "<Directory /var/www/wordpress>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>\n" > /etc/apache2/conf-available/wordpress.conf && \
    a2enconf wordpress

# DirectoryIndex 설정
RUN printf "DirectoryIndex index.php index.html\n" > /etc/apache2/conf-available/dirindex.conf && \
    a2enconf dirindex

# ServerName 설정
RUN printf "ServerName localhost\n" > /etc/apache2/conf-available/servername.conf && \
    a2enconf servername

# Apache rewrite 모듈 활성화
RUN a2enmod rewrite

# .htaccess 파일 생성 (간단한 방법 사용)
RUN echo "# BEGIN WordPress" > /var/www/wordpress/.htaccess && \
    echo "<IfModule mod_rewrite.c>" >> /var/www/wordpress/.htaccess && \
    echo "RewriteEngine On" >> /var/www/wordpress/.htaccess && \
    echo "RewriteBase /" >> /var/www/wordpress/.htaccess && \
    echo "RewriteRule ^index\\.php$ - [L]" >> /var/www/wordpress/.htaccess && \
    echo "RewriteCond %{REQUEST_FILENAME} !-f" >> /var/www/wordpress/.htaccess && \
    echo "RewriteCond %{REQUEST_FILENAME} !-d" >> /var/www/wordpress/.htaccess && \
    echo "RewriteRule . /index.php [L]" >> /var/www/wordpress/.htaccess && \
    echo "</IfModule>" >> /var/www/wordpress/.htaccess && \
    echo "# END WordPress" >> /var/www/wordpress/.htaccess

# 워드프레스가 플러그인/테마/업데이트를 설치할 수 있도록 필요한 폴더 생성
RUN mkdir -p /var/www/wordpress/wp-content/uploads && \
    mkdir -p /var/www/wordpress/wp-content/upgrade && \
    mkdir -p /var/www/wordpress/wp-content/plugins && \
    mkdir -p /var/www/wordpress/wp-content/themes

# 소유자를 www-data로 변경 (이것이 핵심!)
RUN chown -R www-data:www-data /var/www/wordpress

# 권한 설정: wp-content는 777로 설정하여 완전한 쓰기 권한 부여
RUN chmod -R 777 /var/www/wordpress/wp-content/uploads && \
    chmod -R 777 /var/www/wordpress/wp-content/upgrade && \
    chmod -R 777 /var/www/wordpress/wp-content/plugins && \
    chmod -R 777 /var/www/wordpress/wp-content/themes

# 나머지 파일들 권한 설정
RUN find /var/www/wordpress -type d -exec chmod 755 {} + && \
    find /var/www/wordpress -type f -exec chmod 644 {} +

# wp-content 폴더 전체에 대한 추가 권한 설정
RUN chmod -R 777 /var/www/wordpress/wp-content

# .htaccess 파일 권한 설정
RUN chmod 644 /var/www/wordpress/.htaccess && \
    chown www-data:www-data /var/www/wordpress/.htaccess

# 워드프레스 파일이 있는지 확인
RUN ls -la /var/www/wordpress/ && \
    ls -la /var/www/wordpress/wp-content/ && \
    cat /var/www/wordpress/.htaccess && \
    test -f /var/www/wordpress/index.php || (echo "ERROR: index.php not found!" && exit 1)

# 포트 노출
EXPOSE 8080

# Apache 시작
CMD ["apache2-foreground"]
