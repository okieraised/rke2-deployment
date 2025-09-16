FROM ghcr.io/astral-sh/uv:python3.12-bookworm AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=0 \
    UV_LINK_MODE=copy \
    MLFLOW_HOST=0.0.0.0 \
    MLFLOW_PORT=8080 \
    MLFLOW_BACKEND_URI=sqlite:////mlflow/mlflow.db \
    MLFLOW_ARTIFACT_ROOT=/mlflow/artifacts \
    UV_PROJECT_ENVIRONMENT=/opt/venv

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential git curl ca-certificates \
      libpq-dev default-libmysqlclient-dev \
      tzdata locales nano \
    && rm -rf /var/lib/apt/lists/*


COPY certs/rootCA.pem /etc/ssl/custom/rootCA.pem
COPY certs/rootCA.pem /usr/local/share/ca-certificates/rootCA.crt
RUN update-ca-certificates

RUN mkdir -p /mlflow/artifacts /mlflow/logs

WORKDIR /app

COPY pyproject.toml ./
COPY uv.lock ./

RUN uv sync --no-dev

ENV PATH="/opt/venv/bin:${PATH}"

HEALTHCHECK --interval=30s --timeout=5s --start-period=25s --retries=5 \
  CMD curl -fsS "http://127.0.0.1:${MLFLOW_PORT}/" || exit 1


COPY --chown=appuser:appuser <<'EOS' /usr/local/bin/entrypoint.sh
#!/usr/bin/env bash
set -euo pipefail

: "${MLFLOW_HOST:=0.0.0.0}"
: "${MLFLOW_PORT:=8080}"
: "${MLFLOW_BACKEND_URI:=sqlite:////mlflow/mlflow.db}"
: "${MLFLOW_ARTIFACT_ROOT:=/mlflow/artifacts}"
: "${GUNICORN_WORKERS:=4}"
: "${GUNICORN_TIMEOUT:=120}"

echo "[entrypoint] Backend: ${MLFLOW_BACKEND_URI}"
echo "[entrypoint] Artifact root: ${MLFLOW_ARTIFACT_ROOT}"
echo "[entrypoint] Port: ${MLFLOW_PORT}"

# If you want to pre-run DB migrations on boot, set RUN_DB_MIGRATIONS=true
if [[ "${RUN_DB_MIGRATIONS:-false}" == "true" ]]; then
  echo "[entrypoint] Running 'mlflow db upgrade'..."
  mlflow db upgrade "${MLFLOW_BACKEND_URI}" || true
fi

exec mlflow server \
  --app-name oidc-auth \
  --serve-artifacts \
  --host "${MLFLOW_HOST}" \
  --port "${MLFLOW_PORT}" \
  --backend-store-uri "${MLFLOW_BACKEND_URI}" \
  --artifacts-destination "${MLFLOW_ARTIFACT_ROOT}" \
  --default-artifact-root mlflow-artifacts:/artifacts
  --uvicorn-opts="--workers ${GUNICORN_WORKERS:-4} --proxy-headers"
EOS

RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME ["/mlflow"]
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

#  --artifacts-destination "${MLFLOW_ARTIFACT_ROOT}" \