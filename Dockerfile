FROM debian:buster-slim

LABEL maintainer="koheitech001"

RUN apt-get update
RUN apt-cache showpkg squid

RUN apt-get install -yq curl
RUN apt-get install -yq squid=4.6-1+deb10u7
RUN apt-get install -yq apache2-utils

# Set default conf.
RUN mv /etc/squid/squid.conf /etc/squid/squid.conf.origin && chmod a-w /etc/squid/squid.conf.origin

# Remove commented lines.
RUN egrep -v "^\s*(#|$)" /etc/squid/squid.conf.origin | uniq | sort > /etc/squid/squid.conf

ADD entrypoint-digest.sh /sbin/entrypoint.sh
RUN chmod +x /sbin/entrypoint.sh

EXPOSE 22 3128/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]