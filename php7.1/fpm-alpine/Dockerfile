FROM php:7.1-fpm-alpine

LABEL maintainer="Matt Knight <matthew.knight@gmail.com>"

# get things set up ready to receive MediaWiki, cleaning up build dependencies afterwards
RUN set -ex \
    && apk --no-cache add \
        --virtual .phpize-deps $PHPIZE_DEPS \
    && apk --no-cache add \
        git \
        diffutils \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        icu-dev \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && docker-php-ext-configure intl --with-icu-dir=/usr \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-install gd iconv intl mysqli opcache \
    && apk --no-cache del .phpize-deps bash \
    && echo 'Finished installing dependencies'

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# isntall MediaWiki itself
ARG MEDIAWIKI_MAJOR_VERSION=1.28
ARG MEDIAWIKI_MINOR_VERSION=0

ENV MEDIAWIKI_VERSION ${MEDIAWIKI_MAJOR_VERSION}.${MEDIAWIKI_MINOR_VERSION}

VOLUME /var/www/html

RUN set -ex \
    && curl https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_MAJOR_VERSION}.${MEDIAWIKI_MINOR_VERSION}.tar.gz | tar xz \
    && mv $(ls) /usr/src/mediawiki \
    && rm -rf ${MEDIAWIKI_MAJOR_VERSION}.${MEDIAWIKI_MINOR_VERSION} \
    && chown -R www-data:www-data /usr/src/mediawiki

# copy over the entrypoint file and convert to Unix line endings
COPY docker-entrypoint.sh /usr/local/bin/
RUN dos2unix -u /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["php-fpm"]