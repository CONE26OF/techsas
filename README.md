# ConnectOne — Enterprise SaaS Stack

A production-ready, self-hosted enterprise platform for Indian businesses — 15+ open-source applications on a single server with Docker Compose, all accessible under `connectone.tech` subdomains.

## Live Subdomains

| Service | URL | What it does |
|---|---|---|
| **Traefik** | `traefik.connectone.tech` | Reverse proxy + TLS dashboard |
| **Authentik SSO** | `sso.connectone.tech` | Single sign-on for all services |
| **Drive** (Nextcloud) | `drive.connectone.tech` | Cloud file storage, CalDAV/CardDAV |
| **Docs** (ONLYOFFICE) | `docs.connectone.tech` | Online document/spreadsheet editing |
| **Teams** (Zulip) | `teams.connectone.tech` | Team messaging, threaded channels |
| **Chat** (Element) | `chat.connectone.tech` | E2EE WhatsApp/Telegram-style chat |
| **Support** (Chatwoot) | `support.connectone.tech` | Customer support + WhatsApp Business |
| **AI** (Flowise) | `ai.connectone.tech` | LLM pipeline & chatbot builder |
| **LLM** (Open WebUI) | `llm.connectone.tech` | Chat UI for local AI models |
| **VPN** (Headscale) | `vpn.connectone.tech` | Zero-trust WireGuard mesh |
| **VPN UI** | `vpn-ui.connectone.tech` | Headscale admin panel |
| **Tunnel** (Pritunl) | `tunnel.connectone.tech` | Enterprise OpenVPN/WireGuard |
| **SIEM** (Wazuh) | `siem.connectone.tech` | Security monitoring + DPDP compliance |
| **Projects** (Plane) | `projects.connectone.tech` | Project & sprint management |
| **ERP** (ERPNext) | `erp.connectone.tech` | GST, GSTR, e-invoicing, inventory |
| **Billing** (Flexprice) | `billing.connectone.tech` | SaaS billing + Razorpay/PayU |
| **Monitor** (Grafana) | `monitor.connectone.tech` | Dashboards, metrics, logs |
| **Storage** (MinIO) | `s3.connectone.tech` | S3-compatible object storage API |
| **Storage UI** | `storage.connectone.tech` | MinIO admin console |

## Stack

| Category | Service | License |
|---|---|---|
| Reverse Proxy | Traefik v3 | MIT |
| SSO / IAM | Authentik | AGPL-3.0 |
| File Storage | Nextcloud CE | GPL-3.0 |
| Document Edit | ONLYOFFICE Docs | AGPL-3.0 |
| Team Chat | Zulip | Apache 2.0 |
| E2EE Messaging | Matrix Synapse + Element | AGPL-3.0 |
| Customer Support | Chatwoot | MIT |
| AI Builder | Flowise | Apache 2.0 |
| LLM Runtime | Ollama + Open WebUI | MIT |
| Zero-Trust VPN | Headscale | BSD-3 |
| Enterprise VPN | Pritunl CE | Enterprise |
| SIEM/XDR | Wazuh | GPL-2.0 |
| Project Mgmt | Plane | AGPL-3.0 |
| ERP / GST | ERPNext v15 | GPL-3.0 |
| SaaS Billing | Flexprice | AGPL-3.0 |
| Monitoring | Grafana + Prometheus + Loki | AGPL-3.0 |
| Object Storage | MinIO | AGPL-3.0 |

## Requirements

- **Server**: 8 vCPU / 32 GB RAM / 400 GB SSD (Hetzner CCX23 or equivalent)
- **OS**: Ubuntu 22.04 LTS or Debian 12
- **Domain**: A wildcard DNS `*.connectone.tech → server IP` (or individual A records per subdomain)
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
find config/ -type f | xargs sed -i 's/REPLACE_BASE_DOMAIN/connectone.tech/g'

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
traefik.connectone.tech      → 147.93.169.215
sso.connectone.tech          → 147.93.169.215
drive.connectone.tech        → 147.93.169.215
docs.connectone.tech         → 147.93.169.215
teams.connectone.tech        → 147.93.169.215
matrix.connectone.tech       → 147.93.169.215
chat.connectone.tech         → 147.93.169.215
support.connectone.tech      → 147.93.169.215
ai.connectone.tech           → 147.93.169.215
llm.connectone.tech          → 147.93.169.215
vpn.connectone.tech          → 147.93.169.215
vpn-ui.connectone.tech       → 147.93.169.215
tunnel.connectone.tech       → 147.93.169.215
siem.connectone.tech         → 147.93.169.215
projects.connectone.tech     → 147.93.169.215
erp.connectone.tech          → 147.93.169.215
billing.connectone.tech      → 147.93.169.215
monitor.connectone.tech      → 147.93.169.215
prometheus.connectone.tech   → 147.93.169.215
s3.connectone.tech           → 147.93.169.215
storage.connectone.tech      → 147.93.169.215
```

Or use a wildcard: `*.connectone.tech → 147.93.169.215`

## Post-Deploy Setup

### Authentik (do this first — gates all other admin UIs)
1. Go to `https://sso.connectone.tech/if/flow/initial-setup/`
2. Set your admin password
3. Create applications + providers for each service

### Zulip (Teams)
1. Go to `https://teams.connectone.tech`
2. Run org setup wizard
3. Configure SAML SSO with Authentik provider

### ERPNext (Indian GST)
1. Go to `https://erp.connectone.tech`
2. Setup wizard → select **India** as country
3. Install **India Localization** app: `bench --site erp.connectone.tech install-app india_compliance`
4. Configure GST settings, GSTIN, HSN/SAC codes
5. Connect Razorpay: ERPNext > Integrations > Razorpay Settings

### Chatwoot (WhatsApp)
1. Go to `https://support.connectone.tech`
2. Create account → Settings → Inboxes → Add Inbox
3. Select **WhatsApp** → enter WhatsApp Business API credentials

### Flowise (AI Chatbot)
1. Go to `https://ai.connectone.tech`
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
