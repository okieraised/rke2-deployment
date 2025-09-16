FROM docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-dvcs-tools:prod-stable

COPY ./certs/rootCA.pem /etc/ssl/certs/homelab-ca.crt

RUN cat /etc/ssl/certs/homelab-ca.crt >> /etc/ssl/certs/ca-certificates.crt || true
