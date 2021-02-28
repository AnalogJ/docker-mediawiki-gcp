FROM docker.io/bitnami/mediawiki:1.33.1
ENV MW_INSTALL_PATH=/opt/bitnami/mediawiki

#USER root

# modify the sql tables to remove references to MyISAM engine (which does not work with GCP Cloud SQL)
# https://phabricator.wikimedia.org/T177477
COPY patches/tables.sql.patch /opt/bitnami/mediawiki/maintenance/tables.sql.patch
COPY patches/httpd-vhost-php.conf.tpl.patch /root/.nami/components/com.bitnami.mediawiki/lib/handlers/webservers/apache/vhosts/httpd-vhost-php.conf.tpl.patch
RUN apt-get update \
    && apt-get install -y patch nano git \
    && cd /opt/bitnami/mediawiki/maintenance/ \
    && patch tables.sql tables.sql.patch \
    && cd /root/.nami/components/com.bitnami.mediawiki/lib/handlers/webservers/apache/vhosts/ \
    && patch httpd-vhost-php.conf.tpl httpd-vhost-php.conf.tpl.patch

# download Composer, used for managing Mediawiki extensions
RUN curl -L -o /usr/local/bin/composer https://getcomposer.org/composer-1.phar \
    && chmod +x /usr/local/bin/composer \
    && composer --help
#
#
## install addl plugins
#RUN cd /opt/bitnami/mediawiki/extensions/ \
#    && curl -L -o GoogleLogin.tar.gz https://extdist.wmflabs.org/dist/extensions/GoogleLogin-REL1_35-dfe43cb.tar.gz \
#    && tar -xf GoogleLogin.tar.gz \
#    && curl -L -o Math.tar.gz https://extdist.wmflabs.org/dist/extensions/Math-REL1_35-a412f37.tar.gz \
#    && tar -xf Math.tar.gz \
#    && curl -L -o /opt/bitnami/mediawiki/extensions/GoogleDocs4MW.tar.gz https://extdist.wmflabs.org/dist/extensions/GoogleDocs4MW-REL1_35-aee6720.tar.gz \
#    && tar -xf GoogleDocs4MW.tar.gz \
#    && curl -L -o /opt/bitnami/mediawiki/extensions/NotebookViewer.tar.gz https://extdist.wmflabs.org/dist/extensions/NotebookViewer-REL1_35-d227198.tar.gz \
#    && tar -xf NotebookViewer.tar.gz \
#    && cd /opt/bitnami/mediawiki/extensions/ \
#    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/Widgets.git \
#    && cd Widgets && composer update --no-dev

COPY ./rootfs/ /
RUN cd /opt/bitnami/mediawiki && composer update --no-dev
#USER 1001
