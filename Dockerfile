FROM localhost:5000/wordpress:4.9-fpm-alpine

# Install extra PHP extensions
RUN apk add --no-cache --virtual .build-deps postgresql-dev

RUN docker-php-ext-configure pgsql --with-pgsql=/usr
RUN docker-php-ext-install pgsql

RUN runDeps="$( \
		scanelf --needed --nobanner --recursive \
			/usr/local/lib/php/extensions \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" && apk add --virtual .wordpress-phpexts-rundeps $runDeps;
RUN apk del .build-deps

ADD ./postgresql-for-wordpress/pg4wp /usr/src/wordpress/pg4wp
ADD ./docker-entrypoint2.sh          /usr/local/bin/docker-entrypoint2.sh

ENTRYPOINT ["docker-entrypoint2.sh"]
CMD ["php-fpm"]