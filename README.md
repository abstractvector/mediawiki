# MediaWiki PHP Docker Container

This is a Git repo of the Docker image for [MediaWiki](https://www.mediawiki.org/wiki/MediaWiki). See [the Docker Hub page](https://hub.docker.com/r/abstractvector/mediawiki/) for more information. This image available the latest version of MediaWiki running in PHP 7.1 using FPM, including all the necessary PHP extensions and filesystem utilities to run MediaWiki.

## Configuration

The image platform is highly opinionated but allows for configuration of MediaWiki itself. When started for the first time, the MediaWiki installer will be launched, allowing the user to configure the installation parameters.

A fully loaded `docker run` command looks as follows:

````
docker run -v /path/to/my/data/volume:/var/www/html -p 9000:9000 --link mysql abstractvector/mediawiki:1.28.0-php7.1-fpm-alpine
````

### Arguments & Environment Variables

For convenience, the `MEDIAWIKI_VERSION` environment variable is set to the full version of MediaWiki running in the image. For example `MEDIAWIKI_VERSION=1.28.0`. Note that this is set at build time, and changing this at run-time has no effect.

If you wish to change the version of MediaWiki being installed when building the image, you should use the build arguments `MEDIAWIKI_MAJOR_VERSION` and `MEDIAWIKI_MINOR_VERSION`. For example: `MEDIAWIKI_MAJOR_VERSION=1.28` and `MEDIAWIKI_MINOR_VERSION=0`

### Volumes

The MediaWiki files are exposed in a volume mount at `/var/www/html`.

### Ports

As per the parent PHP-FPM image, the container will expose port `9000` for FastCGI binding.

### Links

Because the MediaWiki installer runs at first-launch, there is no requirement for a MySQL database link, however this may be desirable.

## Server

Sample nginx config:

````
upstream docker-mediawiki {
  server mediawiki:9000;
}

server {
  listen 80;
  server_name wiki.example.com;

  root /var/www/html;
  index index.php;

  location / {
    try_files $uri $uri/ @rewrite;
  }

  location @rewrite {
    rewrite ^/(.*)$ /index.php?title=$1&$args;
  }

  location ^~ /maintenance/ {
    return 403;
  }

  location ~* \.php$ {
    fastcgi_param  SCRIPT_FILENAME /var/www/html$fastcgi_script_name;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass docker-mediawiki;
    fastcgi_index index.php;
    include fastcgi_params;
  }

  location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
    try_files $uri /index.php;
    expires max;
    log_not_found off;
  }

  location = /_.gif {
    expires max;
    empty_gif;
  }

  location ^~ /cache/ {
    deny all;
  }

  location /dumps {
    root /data/mediawiki/local;
    autoindex on;
  }

  location ^~ /images/ {
    # empty just to stop PHP being executed in here
  }

}
````

## Docker Compose

````
version: "2"

services:
  mysql:
    image: mysql:latest
    restart: always
    volumes:
      - /data/mysql/data:/var/lib/mysql
    environment:
      MYSQL_EMPTY_ROOT_PASSWORD: "yes"

  mediawiki:
    image: abstractvector/mediawiki:1.28.0-php7.1-fpm-alpine
    restart: always
    links:
      - mysql
    volumes:
      - /path/to/my/data/volume:/var/www/html

  nginx:
    image: nginx:1.11
    restart: always
    ports:
      - 80:80
      - 443:443
    links:
      - mediawiki
    volumes:
      - /path/to//mediawiki-nginx.conf:/etc/nginx/conf.d/mediawiki-nginx.conf
      - /path/to/my/data/volume:/var/www/html
````