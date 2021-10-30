FROM docker.io/bitnami/mediawiki:1.33.1
ENV MW_INSTALL_PATH=/opt/bitnami/mediawiki

#USER root

# modify the sql tables to remove references to MyISAM engine (which does not work with GCP Cloud SQL)
# https://phabricator.wikimedia.org/T177477
COPY patches/tables.sql.patch /opt/bitnami/mediawiki/maintenance/tables.sql.patch
COPY patches/httpd-vhost-php.conf.tpl.patch /root/.nami/components/com.bitnami.mediawiki/lib/handlers/webservers/apache/vhosts/httpd-vhost-php.conf.tpl.patch
RUN apt-get update \
    && apt-get install -y patch nano git ca-certificates \
    && sed -i -e 's=^mozilla/DST_Root_CA_X3.crt=!mozilla/DST_Root_CA_X3.crt=' /etc/ca-certificates.conf \
    && update-ca-certificates \
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
# install addl plugins
RUN cd /opt/bitnami/mediawiki/extensions/ \
    && mkdir -p MultimediaViewer \
    && curl -L -o MultimediaViewer.tar.gz https://gerrit.wikimedia.org/r/plugins/gitiles/mediawiki/extensions/MultimediaViewer/+archive/refs/heads/REL1_33.tar.gz \
    && tar -xvf MultimediaViewer.tar.gz --strip 1 -C MultimediaViewer \

    && mkdir -p ParserFunctions \
    && curl -L -o ParserFunctions.tar.gz https://github.com/wikimedia/mediawiki-extensions-ParserFunctions/archive/REL1_33.tar.gz \
    && tar -xvf ParserFunctions.tar.gz --strip 1 -C ParserFunctions \

    && mkdir -p Math \
    && curl -L -o Math.tar.gz https://github.com/wikimedia/mediawiki-extensions-Math/archive/REL1_33.tar.gz \
    && tar -xvf Math.tar.gz --strip 1 -C Math \

    && git clone https://github.com/xeyownt/mediawiki-mathjax MathJax \

    && git clone https://github.com/wikimedia/mediawiki-extensions-VisualEditor.git VisualEditor \
    && cd VisualEditor \
    && git checkout f64e411614a15e4028843c6f8199c3c5f3c08f1d \
    && git submodule update --init && cd ../ \

    && mkdir -p WikiEditor \
    && curl -L -o WikiEditor.tar.gz https://github.com/wikimedia/mediawiki-extensions-WikiEditor/archive/REL1_33.tar.gz \
    && tar -xvf WikiEditor.tar.gz --strip 1 -C WikiEditor \

    && mkdir -p GoogleLogin \
    && curl -L -o GoogleLogin.tar.gz https://github.com/wikimedia/mediawiki-extensions-GoogleLogin/archive/REL1_33.tar.gz \
    && tar -xvf GoogleLogin.tar.gz --strip 1 -C GoogleLogin \
    && cd GoogleLogin && composer update --no-dev && cd ../ \

    && mkdir -p Scribunto \
    && curl -L -o Scribunto.tar.gz https://github.com/wikimedia/mediawiki-extensions-Scribunto/archive/REL1_33.tar.gz \
    && tar -xvf Scribunto.tar.gz --strip 1 -C Scribunto \

    && mkdir -p TemplateData \
    && curl -L -o TemplateData.tar.gz https://github.com/wikimedia/mediawiki-extensions-TemplateData/archive/REL1_33.tar.gz \
    && tar -xvf TemplateData.tar.gz --strip 1 -C TemplateData \

    && mkdir -p TemplateStyles \
    && curl -L -o TemplateStyles.tar.gz https://github.com/wikimedia/mediawiki-extensions-TemplateStyles/archive/REL1_33.tar.gz \
    && tar -xvf TemplateStyles.tar.gz --strip 1 -C TemplateStyles \
    && cd TemplateStyles && composer install --no-dev && cd ../ \

    && mkdir -p Citoid \
    && curl -L -o Citoid.tar.gz https://github.com/wikimedia/mediawiki-extensions-Citoid/archive/REL1_33.tar.gz \
    && tar -xvf Citoid.tar.gz --strip 1 -C Citoid \
    && cd Citoid && composer install --no-dev && cd ../ \

    && mkdir -p CodeMirror \
    && curl -L -o CodeMirror.tar.gz https://github.com/wikimedia/mediawiki-extensions-CodeMirror/archive/REL1_33.tar.gz \
    && tar -xvf CodeMirror.tar.gz --strip 1 -C CodeMirror \

    && mkdir -p MobileFrontend \
    && curl -L -o MobileFrontend.tar.gz https://github.com/wikimedia/mediawiki-extensions-MobileFrontend/archive/REL1_33.tar.gz \
    && tar -xvf MobileFrontend.tar.gz --strip 1 -C MobileFrontend \

    && mkdir -p NotebookViewer \
    && curl -L -o NotebookViewer.tar.gz https://github.com/wikimedia/mediawiki-extensions-NotebookViewer/archive/REL1_33.tar.gz \
    && tar -xvf NotebookViewer.tar.gz --strip 1 -C NotebookViewer \
    && cd NotebookViewer && composer install --no-dev && cd ../ \

    && mkdir -p GoogleDocs4MW \
    && curl -L -o GoogleDocs4MW.tar.gz https://github.com/wikimedia/mediawiki-extensions-GoogleDocs4MW/archive/REL1_33.tar.gz \
    && tar -xvf GoogleDocs4MW.tar.gz --strip 1 -C GoogleDocs4MW \

    && mkdir -p Widgets \
    && curl -L -o Widgets.tar.gz https://github.com/wikimedia/mediawiki-extensions-Widgets/archive/REL1_33.tar.gz \
    && tar -xvf Widgets.tar.gz --strip 1 -C Widgets \
    && cd Widgets && composer update --no-dev && cd ../ \

    && cd /opt/bitnami/mediawiki/skins \

    && mkdir -p MinervaNeue \
    && curl -L -o MinervaNeue.tar.gz https://github.com/wikimedia/mediawiki-skins-MinervaNeue/archive/REL1_33.tar.gz \
    && tar -xvf MinervaNeue.tar.gz --strip 1 -C MinervaNeue \

    && mkdir -p Tweeki \
    && curl -L -o Tweeki.tar.gz https://github.com/thaider/Tweeki/archive/v1.1.2.tar.gz \
    && tar -xvf Tweeki.tar.gz --strip 1 -C Tweeki


COPY ./rootfs/ /
RUN cd /opt/bitnami/mediawiki && composer update --no-dev
#USER 1001
