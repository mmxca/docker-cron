#!/bin/sh

set -e

# if there is an env var DOCKER_CRON add its contents to the crontab

if [[ -n "${DOCKER_CRONTAB}" ]]; then
    echo "Adding: ${DOCKER_CRONTAB} to crontab"
    echo "${DOCKER_CRONTAB}" >> /var/spool/cron/crontabs/root
    echo "" >> /var/spool/cron/crontabs/root
fi

# run cron(d) in foreground
crond -f
