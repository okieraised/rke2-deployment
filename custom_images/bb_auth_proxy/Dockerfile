FROM docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-auth-proxy:prod-stable

COPY ./certs/rootCA.pem /etc/ssl/certs/homelab-ca.crt

RUN cat /etc/ssl/certs/homelab-ca.crt >> /etc/ssl/certs/ca-certificates.crt || true
