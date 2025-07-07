FROM dunglas/frankenphp:alpine

# this Dockerfile installs the PHP debug build
# this prevents the error from happening

ENV PHPIZE_DEPS="\
	autoconf \
	dpkg-dev \
	file \
	g++ \
	gcc \
	libc-dev \
	make \
	pkgconfig \
	re2c"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache \
	$PHPIZE_DEPS \
	argon2-dev \
	curl-dev \
	oniguruma-dev \
	readline-dev \
	libsodium-dev \
	sqlite-dev \
	openssl-dev \
	libxml2-dev \
	zlib-dev \
	bison \
	nss-tools \
	# file watcher
	libstdc++ \
	linux-headers \
	# Dev tools \
	git \
	clang \
	cmake \
	llvm \
	gdb \
	valgrind \
	neovim \
	zsh \
	libtool && \
	echo 'set auto-load safe-path /' > /root/.gdbinit

WORKDIR /usr/local/src/php
RUN git clone --branch=PHP-8.4 https://github.com/php/php-src.git . && \
	# --enable-embed is only necessary to generate libphp.so, we don't use this SAPI directly
	./buildconf --force && \
	EXTENSION_DIR=/usr/lib/frankenphp/modules ./configure \
		--enable-embed \
		--enable-zts \
		--disable-zend-signals \
		--enable-zend-max-execution-timers \
        --enable-opcache \
        --with-config-file-path="$PHP_INI_DIR" \
    	--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
    	--enable-option-checking=fatal \
        --with-pic \
        --enable-mbstring \
        --enable-mysqlnd \
        --with-password-argon2 \
        --with-sodium=shared \
        --with-pdo-sqlite=/usr \
    	--with-sqlite3=/usr \
    	--with-curl \
    	--with-openssl \
    	--with-readline \
    	--with-zlib \
    	--enable-debug \
        --with-pear && \
	make -j"$(nproc)" && \
	make install && \
	ldconfig /etc/ld.so.conf.d && \
		mkdir -p /etc/frankenphp/php.d && \
			cp php.ini-development /etc/frankenphp/php.ini && \
			echo "zend_extension=opcache.so" >> /etc/frankenphp/php.ini && \
			echo "opcache.enable=1" >> /etc/frankenphp/php.ini && \
	php --version