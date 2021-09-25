#!/bin/bash
. `pwd`/../.env
php /var/www/scripts/wait-for-db.php
if [ ! -d ".git" ]; then
    git clone --progress --single-branch --depth 1 --branch "${VERSION_NEXTCLOUD}" --recurse-submodules -j 4 https://github.com/nextcloud/server /tmp/nextcloud
    rsync -r /tmp/nextcloud/ .
    mkdir data
    chown -R www-data:www-data .
fi
if [[ ! -f "config/config.php" && ${AUTOINSTALL} -eq 1 ]]; then
    if [ ! -z "${POSTGRES_HOST}"]; then
        runuser -u www-data -- php occ maintenance:install --verbose --database=pgsql --database-name=${POSTGRES_DB} --database-host=${POSTGRES_HOST} --database-port= --database-user=${POSTGRES_USER} --database-pass=${POSTGRES_PASSWORD} --admin-user=${NEXTCLOUD_ADMIN_USER} --admin-pass=${NEXTCLOUD_ADMIN_PASSWORD} --admin-email=${NEXTCLOUD_ADMIN_EMAIL}
    elif [ ! -z "${MYSQL_HOST}"]; then
        runuser -u www-data -- php occ maintenance:install --verbose --database=mysql --database-name=${POSTGRES_DB} --database-host=${POSTGRES_HOST} --database-port= --database-user=${POSTGRES_USER} --database-pass=${POSTGRES_PASSWORD} --admin-user=${NEXTCLOUD_ADMIN_USER} --admin-pass=${NEXTCLOUD_ADMIN_PASSWORD} --admin-email=${NEXTCLOUD_ADMIN_EMAIL}
    fi
    runuser -u www-data -- php occ config:system:set default_phone_region ${DEFAULT_PHONE_REGION}
fi
php-fpm
