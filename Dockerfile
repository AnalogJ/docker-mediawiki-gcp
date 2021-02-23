FROM docker.io/bitnami/mediawiki:1.35.1

USER root

# modify the sql tables to remove references to MyISAM engine (which does not work with GCP Cloud SQL)
# https://phabricator.wikimedia.org/T177477
COPY patches/tables.sql.patch /opt/bitnami/mediawiki/maintenance/tables.sql.patch
RUN apt-get update \
    && apt-get install -y patch nano \
    && cd /opt/bitnami/mediawiki/maintenance/ \
    && patch tables.sql tables.sql.patch

# download Composer, used for managing Mediawiki extensions
RUN curl -L -o /usr/local/bin/composer https://getcomposer.org/composer-1.phar \
    && chmod +x /usr/local/bin/composer \
    && composer --help

COPY ./rootfs/ /
RUN cd /opt/bitnami/mediawiki && composer update --no-dev && chown 1001:1001 -R /opt/bitnami/mediawiki/
USER 1001
