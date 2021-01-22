#!/bin/bash
set -e

if ! [ -f /app/data/.initialized ]; then
	  echo "Fresh installation, setting up data directory..."

	  cp /app/code/paperless.conf.setup /app/data/paperless.conf

	  sed -i "s/%PAPERLESS_CONSUME_REDISHOST%/${CLOUDRON_REDIS_HOST}/g" /app/data/paperless.conf
	  sed -i "s/%PAPERLESS_CONSUME_REDISPORT%/${CLOUDRON_REDIS_PORT}/g" /app/data/paperless.conf
#	  sed -i "s/%PAPERLESS_CONSUME_REDISPASS%/${CLOUDRON_REDIS_PASSWORD}/g" /app/data/paperless.conf
	  sed -i "s/%PAPERLESS_CONSUME_DB_HOST%/${CLOUDRON_POSTGRESQL_HOST}/g" /app/data/paperless.conf
	  sed -i "s/%PAPERLESS_CONSUME_DB_PORT%/${CLOUDRON_POSTGRESQL_PORT}/g" /app/data/paperless.conf
	  sed -i "s/%PAPERLESS_CONSUME_DB_NAME%/${CLOUDRON_POSTGRESQL_DATABASE}/g" /app/data/paperless.conf
	  sed -i "s/%PAPERLESS_CONSUME_DB_USER%/${CLOUDRON_POSTGRESQL_USERNAME}/g" /app/data/paperless.conf
          sed -i "s/%PAPERLESS_CONSUME_DB_PASS%/${CLOUDRON_POSTGRESQL_PASSWORD}/g" /app/data/paperless.conf

#	  sed -i "s/%PAPERLESS_CONSUME_MAIL_HOST%/${MAIL_IMAP_SERVER}/g" /app/data/paperless.conf
#	  sed -i "s/%PAPERLESS_CONSUME_MAIL_PORT%/${MAIL_IMAP_PORT}/g" /app/data/paperless.conf
#	  sed -i "s/%PAPERLESS_CONSUME_MAIL_USER%/${MAIL_IMAP_USERNAME}/g" /app/data/paperless.conf
#	  sed -i "s/%PAPERLESS_CONSUME_MAIL_PASS%/${MAIL_IMAP_PASSWORD}/g" /app/data/paperless.conf

	  python3 /app/code/src/manage.py migrate
	  SECRET=`date +%s|sha256sum|base64|head -c 32`
	  sed -i "s/%PAPERLESS_CONSUME_SECRET%/${SECRET}/g" /app/data/paperless.conf
	  touch /app/data/.initialized


fi
echo "Process migrations"
cd /app/code/src && python3 manage.py migrate
echo "=> Ensure permissions"
chown -Rh cloudron:cloudron /app/data
echo "Starting supervisor"
mkdir -p /run/paperless && touch /run/paperless/supervisord.log
exec /usr/bin/supervisord --configuration /etc/supervisor/supervisord.conf --nodaemon -i Paperless
