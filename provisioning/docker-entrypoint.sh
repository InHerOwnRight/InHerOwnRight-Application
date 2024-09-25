#! /usr/bin/env bash

SITE_DOMAINS=${SITE_DOMAINS:-inherownright.org}

sed -i "s/SITE_DOMAINS/${SITE_DOMAINS}/g" /etc/nginx/sites-available/rails.conf

exec "$@"
