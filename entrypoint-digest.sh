#!/bin/bash
set -e

mkdir -p /var/log/squid
chmod -R 755 /var/log/squid
chown -R proxy:proxy /var/log/squid

SQUID_USER=${SQUID_USER}
SQUID_PASS=${SQUID_PASS}


if ( [ -n "${SQUID_USER}" ] && [ -n "${SQUID_PASS}" ] ); then
  # Create a username/password for ncsa_auth.
  htpasswd -c -i -b /etc/squid/.htpasswd ${SQUID_USER} ${SQUID_PASS}

  sed -i "1 i\\
auth_param digest program /usr/lib/squid/digest_file_auth /etc/squid/.htpasswd\\
auth_param digest children 5 startup=0 idle=1\\
auth_param digest realm proxy\\
auth_param digest nonce_garbage_interval 5 minutes\\
auth_param digest nonce_max_duration 30 minutes\\
auth_param digest nonce_max_count 50\\
acl pauth proxy_auth REQUIRED\\
auth_param digest casesensitive off" /etc/squid/squid.conf

  sed -i "/http_access deny all/ i\\
acl ncsa_users proxy_auth REQUIRED\\
http_access allow ncsa_users" /etc/squid/squid.conf
else
  sed -i "/http_access deny all/ i http_access allow all" /etc/squid/squid.conf
  sed -i "/http_access deny all/d" /etc/squid/squid.conf
  sed -i "/http_access deny manager/d" /etc/squid/squid.conf
fi

# sed -i "logformat timefm %{%Y/%m/%d %H:%M:%S}tl %ts.%03tu %6tr %>a %Ss/%03>Hs %<st %rm %ru %[un %Sh/%<a %mt" /etc/squid/squid.conf
# sed -i "access_log daemon:/var/log/squid/access.log timefm" /etc/squid/squid.conf

# Allow arguments to be passed to squid.
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == squid || ${1} == $(which squid) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# Default behaviour is to launch squid.
if [[ -z ${1} ]]; then
  echo "Starting squid..."
  exec $(which squid) -f /etc/squid/squid.conf -NYCd 1 ${EXTRA_ARGS}
else
  exec "$@"
fi
