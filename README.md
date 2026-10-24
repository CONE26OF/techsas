# TechSAS — Enterprise SaaS Stack for Indian Businesses

A production-ready, self-hosted enterprise platform bundling 15+ open-source applications, deployable on a single server with Docker Compose.

## Stack

| Category | Service | License | URL |
|---|---|---|---|
| Reverse Proxy | Traefik v3 | MIT | `traefik.<domain>` |
| SSO / IAM | Authentik | AGPL-3.0 | `sso.<domain>` |
| File Storage | Nextcloud CE | GPL-3.0 | `files.<domain>` |
| Document Edit | ONLYOFFICE Docs | AGPL-3.0 | `office.<domain>` |
| Team Chat | Zulip | Apache 2.0 | `chat.<domain>` |
| E2EE Messaging | Matrix Synapse + Element | AGPL-3.0 | `element.<domain>` |
| Customer Support | Chatwoot | MIT | `support.<domain>` |
| AI Builder | Flowise | Apache 2.0 | `ai.<domain>` |
| LLM Runtime | Ollama + Open WebUI | MIT | `llm.<domain>` |
| Zero-Trust VPN | Headscale | BSD-3 | `vpn.<domain>` |
| Enterprise VPN | Pritunl CE | Enterprise | `pritunl.<domain>` |
| SIEM/XDR | Wazuh | GPL-2.0 | `siem.<domain>` |
| Project Mgmt | Plane | AGPL-3.0 | `plane.<domain>` |
| ERP / GST | ERPNext v15 | GPL-3.0 | `erp.<domain>` |
| SaaS Billing | Flexprice | AGPL-3.0 | `billing.<domain>` |
| Monitoring | Grafana + Prometheus + Loki | AGPL-3.0 | `grafana.<domain>` |
| Object Storage | MinIO | AGPL-3.0 | `s3.<domain>` |

## Requirements

- **Server**: 8 vCPU / 32 GB RAM / 400 GB SSD (Hetzner CCX23 or equivalent)
- **OS**: Ubuntu 22.04 LTS or Debian 12
- **Domain**: A wildcard DNS `*.yourdomain.com → server IP` (or individual A records per subdomain)
- **Ports open**: 80, 443, 1194/udp (OpenVPN), 1195/udp (WireGuard), 3478/udp (STUN), 51820/udp (WireGuard mesh)

## Quick Start

### 1. Prepare the server

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh
usermod -aG docker $USER

# Install Docker Compose plugin
apt-get install -y docker-compose-plugin

# Clone repo
git clone https://github.com/CONE26OF/techsas.git
cd techsas
```

### 2. Configure environment

```bash
cp .env.example .env
nano .env
```

Fill in all values — pay special attention to:
- `BASE_DOMAIN` — your actual domain
- `ACME_EMAIL` — for Let's Encrypt certificates
- All `*_PASSWORD` fields — use strong, unique passwords (generate with `openssl rand -hex 32`)

### 3. Configure services

Update domain placeholders in config files:
```bash
# Replace REPLACE_BASE_DOMAIN with your domain in all config files
find config/ -type f | xargs sed -i 's/REPLACE_BASE_DOMAIN/yourdomain.com/g'

# Replace password placeholders in synapse config
sed -i "s/REPLACE_SYNAPSE_DB_PASSWORD/${SYNAPSE_DB_PASSWORD}/g" config/synapse/homeserver.yaml
sed -i "s/REPLACE_REDIS_PASSWORD/${REDIS_PASSWORD}/g" config/synapse/homeserver.yaml
sed -i "s/REPLACE_MATRIX_REGISTRATION_SECRET/${MATRIX_REGISTRATION_SECRET}/g" config/synapse/homeserver.yaml
```

### 4. Deploy

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Start infrastructure first
./scripts/deploy.sh infra

# Wait ~30 seconds, then deploy everything
./scripts/deploy.sh all

# Set up MinIO buckets (after MinIO is healthy)
./scripts/setup-minio.sh
```

### 5. DNS Setup

Point these DNS A records to your server IP (`147.93.169.215`):

```
traefik.yourdomain.com      → 147.93.169.215
sso.yourdomain.com          → 147.93.169.215
files.yourdomain.com        → 147.93.169.215
office.yourdomain.com       → 147.93.169.215
chat.yourdomain.com         → 147.93.169.215
matrix.yourdomain.com       → 147.93.169.215
element.yourdomain.com      → 147.93.169.215
support.yourdomain.com      → 147.93.169.215
ai.yourdomain.com           → 147.93.169.215
llm.yourdomain.com          → 147.93.169.215
vpn.yourdomain.com          → 147.93.169.215
vpn-ui.yourdomain.com       → 147.93.169.215
pritunl.yourdomain.com      → 147.93.169.215
siem.yourdomain.com         → 147.93.169.215
plane.yourdomain.com        → 147.93.169.215
erp.yourdomain.com          → 147.93.169.215
billing.yourdomain.com      → 147.93.169.215
grafana.yourdomain.com      → 147.93.169.215
prometheus.yourdomain.com   → 147.93.169.215
s3.yourdomain.com           → 147.93.169.215
minio-console.yourdomain.com → 147.93.169.215
```

Or use a wildcard: `*.yourdomain.com → 147.93.169.215`

## Post-Deploy Setup

### Authentik (do this first — gates all other admin UIs)
1. Go to `https://sso.yourdomain.com/if/flow/initial-setup/`
2. Set your admin password
3. Create applications + providers for each service

### Zulip
1. Go to `https://chat.yourdomain.com`
2. Run org setup wizard
3. Configure SAML SSO with Authentik provider

### ERPNext (Indian GST)
1. Go to `https://erp.yourdomain.com`
2. Setup wizard → select **India** as country
3. Install **India Localization** app: `bench --site erp.yourdomain.com install-app india_compliance`
4. Configure GST settings, GSTIN, HSN/SAC codes
5. Connect Razorpay: ERPNext > Integrations > Razorpay Settings

### Chatwoot (WhatsApp)
1. Go to `https://support.yourdomain.com`
2. Create account → Settings → Inboxes → Add Inbox
3. Select **WhatsApp** → enter WhatsApp Business API credentials

### Flowise (AI Chatbot)
1. Go to `https://ai.yourdomain.com`
2. Create a flow using Ollama nodes
3. First pull a model: `docker exec ollama ollama pull llama3.2:3b`
4. Embed chatbot widget in your Chatwoot inbox

## Security Notes

- All admin UIs are protected behind Authentik forward auth
- Let's Encrypt TLS auto-renewed by Traefik
- Wazuh agents monitor all containers (DPDP Act Rule 6 compliance)
- Logs retained 1 year in Loki + MinIO
- Internal services are on `techsas_internal` network (not internet-accessible)

## Useful Commands

```bash
# View all running containers
docker compose ps

# Tail logs for a service
docker compose logs -f nextcloud

# Restart a single service
docker compose restart chatwoot

# Update all images
docker compose pull && docker compose up -d

# Check Traefik routing
docker compose logs traefik | grep -i "error\|warn"

# Backup postgres
docker exec postgres pg_dumpall -U postgres > backup_$(date +%Y%m%d).sql

# Enter a container shell
docker exec -it nextcloud bash
```

## Architecture

```
Internet → Traefik (80/443) → [All Services via internal network]
                            ↕
                       Authentik SSO
                       (forward auth for all admin UIs)

WireGuard mesh (Headscale :51820/udp) → Direct infra access
OpenVPN/WG (Pritunl :1194-1195/udp) → Enterprise customer VPN
```

## License

All bundled software is open-source. See individual service licenses.
This deployment configuration: MIT.
