FROM php:7.4-apache
ENV EXT_APCU_VERSION=5.1.17
ENV VERSION_GLPI 9.5.7
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        wget \
        libbz2-dev\
        libzip-dev \
        libxml2-dev \
        libldap2-dev \
        libonig-dev \
        libcurl4-gnutls-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install  bz2 zip xmlrpc ldap mbstring curl simplexml intl mysqli opcache exif 
RUN docker-php-source extract \
    && mkdir -p /usr/src/php/ext/apcu \
    && curl -fsSL https://github.com/krakjoe/apcu/archive/v$EXT_APCU_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/apcu --strip 1 \
    && docker-php-ext-install apcu \
    # cleanup
    && docker-php-source delete
WORKDIR /var/www/html/
RUN wget "https://github.com/glpi-project/glpi/releases/download/${VERSION_GLPI}/glpi-${VERSION_GLPI}.tgz" -O - | tar -xz && mv glpi/* . && mv glpi/.ht* . && rm -rf glpi
RUN chown -R www-data .
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
