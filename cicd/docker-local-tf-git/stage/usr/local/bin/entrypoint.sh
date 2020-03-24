#!/bin/sh

set -e

(
    export HOME=/var/cache/nginx
    /usr/bin/spawn-fcgi \
        -s /var/run/fcgiwrap.socket \
        -F 4 \
        -u nginx \
        -g nginx \
        -U nginx \
        -G nginx \
        /usr/bin/fcgiwrap
)

exec "$@"
