FROM alpine:3.13.5

# Whenever possible, install tools using the distro package manager
RUN apk add --no-cache tini ttyd socat nginx unzip openssl openssh ca-certificates  && \
    # Do some configuration for nginx
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    mkdir /run/nginx && \
    echo "server { listen 80 default_server; root /var/www/localhost/htdocs; location / { try_files \$uri /index.html; } }" > /etc/nginx/conf.d/default.conf && \
    echo "<html><head><title>Welcome to Nginx</title></head><body><h1>Nginx works!</h1></body></html>" > /var/www/localhost/htdocs/index.html && \
    chown -R 0:82 /var/www/localhost/htdocs && \
    # Configure a nice terminal
    echo "export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /etc/profile && \
    # Fake poweroff (stops the container from the inside by sending SIGTERM to PID 1)
    echo "alias poweroff='kill 1'" >> /etc/profile

ENV TINI_KILL_PROCESS_GROUP=1

EXPOSE 7681 4040 80
ENTRYPOINT ["/sbin/tini", "--"]
CMD [ "ttyd", "-s", "3", "-t", "titleFixed=/bin/sh", "-t", "rendererType=webgl", "-t", "disableLeaveAlert=true", "/bin/sh", "-i", "-l" ]