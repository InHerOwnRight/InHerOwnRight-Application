#! /usr/bin/env bash

SITE_DOMAINS=${SITE_DOMAINS:-inherownright.org}

sed -i "s/SITE_DOMAINS/${SITE_DOMAINS}/g" /etc/nginx/sites-available/rails.conf
sed -i "s/SITE_DOMAINS/${SITE_DOMAINS}/g" /etc/nginx/sites-available/rails-tls.conf

#certbot -n --nginx --register-unsafely-without-email --agree-tos --domains ${SITE_DOMAINS}

exec "$@"
