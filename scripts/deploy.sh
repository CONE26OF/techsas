#!/bin/bash
# =============================================================
# TechSAS deployment script
# Usage: ./scripts/deploy.sh [stack]
#   stack: all | infra | storage | chat | support | security |
#          productivity | monitoring
# =============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

# ── Pre-flight checks ──────────────────────────────────────────
if [ ! -f .env ]; then
  echo "❌  .env not found. Copy .env.example and fill in values:"
  echo "    cp .env.example .env && nano .env"
  exit 1
fi

source .env

if [ -z "$BASE_DOMAIN" ] || [ "$BASE_DOMAIN" = "yourdomain.com" ]; then
  echo "❌  BASE_DOMAIN is not set in .env"
  exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ] || [ "$POSTGRES_PASSWORD" = "changeme" ]; then
  echo "❌  POSTGRES_PASSWORD looks like a default. Set real passwords in .env"
  exit 1
fi

echo "🚀  Deploying TechSAS to domain: $BASE_DOMAIN"

# ── Pull latest images ─────────────────────────────────────────
echo "📥  Pulling latest images..."
docker compose pull 2>/dev/null || true

# ── Start specified stack ──────────────────────────────────────
STACK="${1:-all}"

case "$STACK" in
  all)
    docker compose up -d --remove-orphans
    ;;
  infra)
    docker compose up -d traefik postgres mongodb redis minio --remove-orphans
    ;;
  storage)
    docker compose up -d nextcloud nextcloud-cron onlyoffice --remove-orphans
    ;;
  chat)
    docker compose up -d zulip synapse element --remove-orphans
    ;;
  support)
    docker compose up -d chatwoot chatwoot-worker ollama flowise open-webui --remove-orphans
    ;;
  security)
    docker compose up -d authentik-server authentik-worker headscale headscale-ui pritunl wazuh-manager wazuh-indexer wazuh-dashboard --remove-orphans
    ;;
  productivity)
    docker compose up -d plane-web plane-api plane-worker erpnext erpnext-backend erpnext-mariadb erpnext-scheduler flexprice --remove-orphans
    ;;
  monitoring)
    docker compose up -d prometheus grafana loki promtail node-exporter cadvisor --remove-orphans
    ;;
  *)
    echo "❌  Unknown stack: $STACK"
    echo "    Valid options: all | infra | storage | chat | support | security | productivity | monitoring"
    exit 1
    ;;
esac

echo ""
echo "✅  Deployment complete!"
echo ""
echo "📊  Service URLs:"
echo "  Traefik dashboard: https://traefik.${BASE_DOMAIN}"
echo "  SSO (Authentik):   https://sso.${BASE_DOMAIN}"
echo "  Drive (Nextcloud): https://drive.${BASE_DOMAIN}"
echo "  Docs (OnlyOffice): https://docs.${BASE_DOMAIN}"
echo "  Team chat (Zulip): https://chat.${BASE_DOMAIN}"
echo "  Messenger (E2EE):  https://messenger.${BASE_DOMAIN}"
echo "  Support (Chatwoot):https://support.${BASE_DOMAIN}"
echo "  AI builder:        https://ai.${BASE_DOMAIN}"
echo "  LLM chat:          https://llm.${BASE_DOMAIN}"
echo "  VPN (Headscale):   https://vpn.${BASE_DOMAIN}"
echo "  VPN UI:            https://vpn-ui.${BASE_DOMAIN}"
echo "  Tunnel (Pritunl):  https://tunnel.${BASE_DOMAIN}"
echo "  SIEM (Wazuh):      https://siem.${BASE_DOMAIN}"
echo "  Projects (Plane):  https://projects.${BASE_DOMAIN}"
echo "  ERP (ERPNext):     https://erp.${BASE_DOMAIN}"
echo "  Billing:           https://billing.${BASE_DOMAIN}"
echo "  Monitor (Grafana): https://monitor.${BASE_DOMAIN}"
echo "  Storage (MinIO):   https://storage.${BASE_DOMAIN}"
echo ""
echo "⚠️   First run: also execute ./scripts/setup-minio.sh"
