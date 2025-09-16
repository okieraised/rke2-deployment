FROM docker-hub.packages.atlassian.com/google/pause:latest


COPY ./certs/rootCA.pem /usr/local/share/ca-certificates/homelab-ca.crt


RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*
