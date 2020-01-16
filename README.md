# docker-cron
This is docker image for running cronjobs via a container. Its main purpose is, to trigger other docker containers via cron.

A possible use case are backups - you want to have regular backups for you dockerized application stack with neither setting up a cronjob **inside** your _database_ container nor setting up cron on the _host_.

With this container you can easily achieve this, by exposing the docker socket from the host to this container and setting up cronjobs via an _environment variable_.

## Usage

For setting up cronjobs, you have to pass an _environment variable_ `DOCKER_CRONTAB` to it - it can be _"multi-line", i.e. contain multiple entries by separating them with `\n`.

Although you can run arbitrary commands _inside_ this container, you likely want to run some sort of docker command _from inside_ the container communicating with the _outside_ docker daemon, for this you have to pass the docket socket to it.

```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock:ro \
       -e DOCKER_CRONTAB=\
       '*/5       *       *       *       *       docker info > /cron-env/docker-info.txt' \
       zalari/docker-cron
```

### with docker-compose
`docker-compose` is also conveniently provided in this image and this allows for adding cron functionality quite easily to your applications stacks:

```yaml
  # ...

  #this is a special service for exporting something to stdout
  #to use: docker-compose run --rm -T dump_db_out > db_dump/dump.sql
  dump_db_out:
    image: mysql:5
    # usually you would want some more params for mysqldump
    command: mysqldump
    depends_on:
      - db
   
  
  cron:
    image: zalari/docker-cron
    volumes:
      - ./docker-compose.yml:/cron-env/project/docker-compose.yml
      - ./db_dump:/cron-env/project/db_dump
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - |
        DOCKER_CRONTAB=
        30       22       *       *       * cd /cron-env/project && docker-compose run --rm -T dump_db_out > db_dump/`date +"%m-%d-%y"`-project.sql
        30       22       *       *       * cd /cron-env/project/db_dump && find *.sql -mtime +30 -delete

  
```

## Hints
The image is based on the _rather latest_ `alpine` image and thus _only_ **BusyBox** and **ash** are available for cronjobs; if you need more tooling, simply base your image off this one.

You can also use the _default cronjobs_ from `alpine` if you either _add_ something or _bind-mount_ to the following dirs _in_ the container:
* `/etc/periodic/15min`
* `/etc/periodic/hourly`
* `/etc/periodic/daily`
* `/etc/periodic/weekly`
* `/etc/periodic/monthly`

For listing the actual `crontab` of the _running_ container, simply run: `docker exec container-name cat /var/spool/cron/crontabs/root`



