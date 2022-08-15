docker run --name squid-proxy-digest -d \
  --publish 3127:3128 -p 2221:22 \
  -e SQUID_USER=test \
  -e SQUID_PASS=test \
  fukouhei001/squid-proxy-digest

# /var/log/squid/access.log
