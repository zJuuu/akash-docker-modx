FROM php:7.2-apache
RUN a2enmod rewrite
COPY html/ /var/www/html/
RUN apt-get update && apt-get install -y libmagickwand-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN printf "\n" | pecl install imagick
RUN docker-php-ext-enable imagick


RUN docker-php-ext-install mysqli pdo pdo_mysql simplexml mbstring zip json gd opcache

# install the PHP extensions we need
RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# set timezone
RUN { \
		echo 'date.timezone=GMT+0'; \
	} > /usr/local/etc/php/conf.d/datetime.ini


RUN service apache2 restart
RUN chmod -R 777 .

EXPOSE 80