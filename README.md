# web-terminal

## What is this?
This is a lightweight (~43MB) alpine based docker image that comes pre-packaged with 2 wonderful tools:
* [ttyd](https://github.com/tsl0922/ttyd): is a simple command-line tool for sharing a terminal over the web, using WebSockets.

On top of those, I've added socat, Nginx, OpenSSH, and OpenSSL. 
This allows you to quickly provision an isolated (docker container) that can serve as a base for a lot of tunneling solutions. Use your imagination. :wink:

If you run this with docker option **--rm** (as bellow), keep in mind that docker will remove the container once it gets stopped. This is good if you don't want to leave any garbage behind.

---
# Multi-Arch
This image supports the following architectures: linux/armv7, linux/arm64, linux/386 and linux/amd64.

This means you can get it running on your RaspberryPi!

---
# Usage
```sh
# docker run --rm -d -p 7681:7681 raonigabriel/web-terminal:latest
```
Then access http://localhost:7681 to have a web-based shell. There is no enforced limit on the number of shells, but you can do that if needed, by customizing the ttyd daemon process.

See [here](https://github.com/tsl0922/ttyd#command-line-options) and [here](https://github.com/tsl0922/ttyd/wiki/Client-Options) for more help and the **CMD** line of this image's [Dockerfile](https://github.com/raonigabriel/web-terminal/blob/master/amd64/Dockerfile#L26).


---
## Extras
To terminate the container (and all its shells) from inside, run this aliased version of **poweroff**:
```sh
# poweroff
```
It **WILL NOT** shut down the host, but the container instead. 

---
## Docker options (ports and volumes)
By default, ttyd runs on port 7681 and ngrok opens and admin console on port 4040.

If you want to have access to the ngrok admin console, remember to add **-p 4040:4040** to the docker call:
```sh
# docker run --rm -d -p 4040:4040 -p 7681:7681 raonigabriel/web-terminal:latest
```

If you know you will need access to the container internal ports, (nginx, openssh-server) just use add **-p** to the docker call, for an example:
```sh
# docker run --rm -d -p 80:80 -p 7681:7681 raonigabriel/web-terminal:latest
```

If you want to keep the container after it exits, remove the **--rm** from the call:
```sh
# docker run -d -p 7681:7681 raonigabriel/web-terminal:latest
```

If you want to use any volume(s) from the host, just bind mount it with **-v**, for an example:
```sh
# docker run --rm -d -v /var/run/docker.sock:/var/run/docker.sock -p 7681:7681 raonigabriel/web-terminal:latest
```

---
## Custom (derived) image
You can create your own custom Docker image, inherit from this one then add the tools you want and a non-root user (recomended). See the sample **Dockerfile** bellow for a custom developer image that could be used as standard-sandboxed-environment by javascript developers:
```docker
FROM raonigabriel/web-terminal:latest
RUN apk add --no-cache curl nano git g++ make npm docker-cli && \
    npm install -g yarn typescript @angular/cli && \
    addgroup -g 1000 docker && \
    adduser -s /bin/sh -u 1000 -D -G docker developer && \
    mkdir /home/developer/.ngrok2 && \
    echo "web_addr: 0.0.0.0:4040" > /home/developer/.ngrok2/ngrok.yml && \
    echo "tunnels:" >> /home/developer/.ngrok2/ngrok.yml && \
    echo "  nodejs:" >> /home/developer/.ngrok2/ngrok.yml && \
    echo "    proto: http" >> /home/developer/.ngrok2/ngrok.yml && \
    echo "    addr: 3000" >> /home/developer/.ngrok2/ngrok.yml && \
    chown -R developer:docker /home/developer/.ngrok2

USER developer
WORKDIR /home/developer
CMD [ "ttyd", "-c", "developer:password", "-s", "3", "-t", "titleFixed=/bin/sh", "-t", "rendererType=webgl", "-t", "disableLeaveAlert=true", "/bin/sh", "-i", "-l" ]
``` 
Build, then run it:
 ```sh
# docker build . -t js-box
# docker run --rm --hostname jsbox -d -p 7681:7681 js-box
```


And since this image has the docker-cli, you could even bind-mount the host docker socket to use it from inside the container: 
 ```sh
# docker run --rm --hostname jsbox -v /var/run/docker.sock:/var/run/docker.sock -d -p 7681:7681 js-box
```
We could also use have used socat, openssh tunnels or event ngrok to forward the local docker port (2375) to another host.


---
## Licenses

[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)
