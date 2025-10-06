FROM wordpress:latest

# 시스템 업데이트 및 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 테마 복사
COPY twentytwelve/ /var/www/html/wp-content/themes/twentytwelve/

# wp-config.php 복사
COPY wp-config.php /var/www/html/wp-config.php

# 권한 설정
RUN chown -R www-data:www-data /var/www/html/wp-content/themes/twentytwelve/
RUN chmod -R 755 /var/www/html/wp-content/themes/twentytwelve/

# 포트 노출
EXPOSE 80

# WordPress 시작
CMD ["apache2-foreground"]
