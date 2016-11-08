FROM nginx:latest

MAINTAINER cackharot <cackharot@gmail.com>

VOLUME ["/etc/nginx/conf.d","/etc/nginx/sites-enabled","/var/www/html","/usr/share/nginx/html"]

RUN apt-get update -y

RUN apt-get install -y php5 php5-common php5-cli php5-fpm php5-mysql

COPY ./config/piwik.conf /etc/nginx/sites-enabled/piwik
COPY ./config/piwik.conf /etc/nginx/conf.d/default.conf

COPY ./test/info.php /usr/share/nginx/www/info.php


RUN chsh -s /bin/bash www-data

RUN rm -f /var/log/nginx/*
RUN rm -rf /var/cache/nginx/*
RUN chown www-data:www-data /var/log/nginx -R
RUN chown www-data:www-data /var/cache/nginx -R
RUN chown www-data /var/run

RUN apt-get install -y wget unzip

RUN mkdir -p /opt/piwik && cd /opt/piwik

RUN wget https://builds.piwik.org/piwik.zip

RUN unzip piwik.zip -d /usr/share/nginx/www

RUN chown -R www-data:www-data /usr/share/nginx/www/piwik

RUN echo "always_populate_raw_post_data=-1" >> /etc/php5/fpm/php.ini

CMD service php5-fpm start && su - www-data -c "/usr/sbin/nginx -g 'daemon off;'"
#CMD nginx -g 'daemon off;'
