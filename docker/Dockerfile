# FROM thiennd0903/nginx-php8.1.13:latest
FROM 18110161/php-nginx:8.2.3

# install the PHP extensions we need

RUN set -ex; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  \
  apt-get clean && apt-get update; \
  apt-get install -y --no-install-recommends \
  libjpeg-dev \
  libpng-dev \
  libpq-dev \
  libxml2-dev \
  g++ \
  make \
  automake \
  autoconf \
  libzip-dev \
  libwebp-dev \
  ; \
  \
  docker-php-ext-configure gd --enable-gd --with-jpeg --with-webp; \
  docker-php-ext-install -j "$(nproc)" \
  gd \
  opcache \
  mysqli \
  intl \
  exif \
  pdo \
  pdo_pgsql \
  zip \
  xml \
  intl
  # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
  # apt-mark auto '.*' > /dev/null; \
  # apt-mark manual $savedAptMark; \
  # ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
  # | awk '/=>/ { print $3 }' \
  # | sort -u \
  # | xargs -r dpkg-query -S \
  # | cut -d: -f1 \
  # | sort -u \
  # | xargs -rt apt-mark manual; \
  # \
  # apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  # rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
  echo 'opcache.memory_consumption=128'; \
  echo 'opcache.interned_strings_buffer=8'; \
  echo 'opcache.max_accelerated_files=4000'; \
  echo 'opcache.revalidate_freq=60'; \
  echo 'opcache.fast_shutdown=1'; \
  echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN apt-get clean && apt-get update

RUN apt-get install -y --no-install-recommends \
  git \
  vim \
  wget \
  ssl-cert \
  libfontconfig \
  gnupg \
  jpegoptim \
  optipng \
  unzip

RUN docker-php-ext-install bcmath

# install redis
RUN pecl install redis

# Install Xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN if [ ! -d /usr/local/etc/php/conf-available ]; then mkdir /usr/local/etc/php/conf-available ; fi
RUN mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf-available/docker-php-ext-xdebug.ini
RUN echo 'xdebug.mode = debug' >> /usr/local/etc/php/conf-available/xdebug.ini
RUN echo 'xdebug.discover_client_host = true' >> /usr/local/etc/php/conf-available/xdebug.ini
RUN echo 'xdebug.client_host = host.docker.internal' >> /usr/local/etc/php/conf-available/xdebug.ini
RUN echo 'xdebug.client_port = 9003' >> /usr/local/etc/php/conf-available/xdebug.ini
COPY ./xdebug-switch /usr/local/bin/xdebug-switch
RUN chmod +x /usr/local/bin/xdebug-switch

# enable site
COPY config/site-availables/drupal-recommend /etc/nginx/sites-available/default
COPY config/fastcgi.conf /etc/nginx/fastcgi.conf
COPY config/custom.conf /etc/nginx/conf.d
COPY config/drupal-php.ini /usr/local/etc/php/conf.d/


# set env variable
ENV NGINX_DOCUMENT_ROOT /var/www/html/web

#install composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
  && apt-get install -y nodejs

# install drush
RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.4.2/drush.phar && \
  chmod +x drush.phar && \
  mv drush.phar /usr/local/bin/drush

# Add mssql commandline tool
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list \
  && apt-get update -y \
  && ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev \
  && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

# Add mssql driver
RUN pecl install sqlsrv \
    pdo_sqlsrv; \
    printf "; priority=20\nextension=sqlsrv.so\n" > /usr/local/etc/php/conf.d/sqlsrv.ini; \
    printf "; priority=20\nextension=pdo_sqlsrv.so\n" > /usr/local/etc/php/conf.d/pdo_sqlsrv.ini


WORKDIR /var/www/html
