#!/bin/bash
set -e

if ! [ -f /app/data/.initialized ]; then
	  echo "Fresh installation, setting up data directory..."

	  cp /app/code/paperless.conf /app/data/paperless.conf

	  sed -i "s/%PAPERLESS_CONSUME_REDISHOST%/${CLOUDRON_REDIS_HOST}/g" /app/data/paperless.conf
	  sed -i "s/%PAPERLESS_CONSUME_REDISPORT%/${CLOUDRON_REDIS_PORT}/g" /app/data/paperless.conf
	  sed -i "s/%PAPERLESS_CONSUME_DB_HOST%/${CLOUDRON_POSTGRESQL_HOST}/g" /app/data/paperless.conf
	  sed -i "s/%PAPERLESS_CONSUME_DB_PORT%/${CLOUDRON_POSTGRESQL_PORT}/g" /app/data/paperless.conf
	  sed -i "s/%PAPERLESS_CONSUME_DB_NAME%/${CLOUDRON_POSTGRESQL_DATABASE}/g" /app/data/paperless.conf
	  sed -i "s/%PAPERLESS_CONSUME_DB_USER%/${CLOUDRON_POSTGRESQL_USERNAME}/g" /app/data/paperless.conf
          sed -i "s/%PAPERLESS_CONSUME_DB_PASS%/${CLOUDRON_POSTGRESQL_PASSWORD}/g" /app/data/paperless.conf

	  python3 /app/code/src/manage.py migrate
	  $SECRET= dd if=/dev/urandom bs=1 count=1024 2>/dev/null | sha1sum | awk '{ print $1 }'
	  sed -i "s/%PAPERLESS_CONSUME_SECRET%/${SECRET}/g" /app/data/paperless.conf

	  touch /app/data/.initialized


fi
exec sudo -HEu cloudron python3 "/app/code/src/manage.py" "runserver" "--insecure" "0.0.0.0:8000" 

#exec /usr/bin/supervisord --configuration /etc/supervisor/conf.d/paperless-consumer.service --nodaemon -i PaperlessConsumer
#exec /usr/bin/supervisord --configuration /etc/supervisor/conf.d/paperless-scheduler.service --nodaemon -i PaperlessScheduler
#exec /usr/bin/supervisord --configuration /etc/supervisor/conf.d/paperless-webserver.service --nodaemon -i PaperlessWeb
