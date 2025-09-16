FROM apache/airflow:3.0.6
USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends nano \
  && rm -rf /var/lib/apt/lists/*

USER root
COPY ./rootCA.pem /usr/local/share/ca-certificates/keycloak-ca.crt

RUN update-ca-certificates

RUN echo /usr/local/share/ca-certificates/keycloak-ca.crt >> /home/airflow/.local/lib/python3.12/site-packages/certifi/cacert.pem

USER airflow

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint"]
CMD []