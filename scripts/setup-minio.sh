#!/bin/bash
# =============================================================
# MinIO bucket initialization
# Run after MinIO is healthy: ./scripts/setup-minio.sh
# =============================================================
set -e

source .env

MINIO_ALIAS="techsas"
MINIO_URL="http://localhost:9000"

echo "⏳ Waiting for MinIO to be ready..."
until docker exec minio curl -sf http://localhost:9000/minio/health/live; do
  sleep 2
done

echo "🔗 Configuring MinIO client..."
docker run --rm --network techsas_internal \
  minio/mc alias set ${MINIO_ALIAS} http://minio:9000 "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}"

# Create buckets
BUCKETS=(
  "nextcloud-data"
  "plane-uploads"
  "chatwoot-storage"
  "wazuh-archives"
  "flowise-blobs"
)

for bucket in "${BUCKETS[@]}"; do
  echo "📦 Creating bucket: ${bucket}"
  docker run --rm --network techsas_internal \
    minio/mc mb --ignore-existing ${MINIO_ALIAS}/${bucket}
  # Enable versioning for data buckets
  docker run --rm --network techsas_internal \
    minio/mc version enable ${MINIO_ALIAS}/${bucket}
done

# Wazuh archives — 1-year retention for DPDP compliance
docker run --rm --network techsas_internal \
  minio/mc ilm rule add \
  --expiry-days 365 \
  ${MINIO_ALIAS}/wazuh-archives

echo "✅ MinIO buckets configured successfully."
