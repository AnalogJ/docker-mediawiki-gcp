FROM docker.io/bitnami/mediawiki:1-debian-10

USER root

# modify the sql tables to remove references to MyISAM engine (which does not work with GCP Cloud SQL)
# https://phabricator.wikimedia.org/T177477
COPY patches/tables.sql.patch /opt/bitnami/mediawiki/maintenance/tables.sql.patch
RUN apt-get update \
    && apt-get install -y patch \
    && cd /opt/bitnami/mediawiki/maintenance/ \
    && patch tables.sql tables.sql.patch

USER 1001
