#!/bin/bash
# =============================================================
# PostgreSQL initialization — runs once on first container start
# Creates all required databases and users
# =============================================================
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  -- Nextcloud
  CREATE USER nextcloud WITH PASSWORD '${NEXTCLOUD_DB_PASSWORD:-changeme_nextcloud}';
  CREATE DATABASE nextcloud OWNER nextcloud;

  -- Zulip
  CREATE USER zulip WITH PASSWORD '${ZULIP_DB_PASSWORD:-changeme_zulip}';
  CREATE DATABASE zulip OWNER zulip;
  GRANT ALL PRIVILEGES ON DATABASE zulip TO zulip;

  -- Matrix Synapse
  CREATE USER synapse WITH PASSWORD '${SYNAPSE_DB_PASSWORD:-changeme_synapse}';
  CREATE DATABASE synapse
    ENCODING 'UTF8'
    LC_COLLATE='C'
    LC_CTYPE='C'
    template=template0
    OWNER synapse;

  -- Chatwoot
  CREATE USER chatwoot WITH PASSWORD '${CHATWOOT_DB_PASSWORD:-changeme_chatwoot}';
  CREATE DATABASE chatwoot OWNER chatwoot;

  -- Authentik
  CREATE USER authentik WITH PASSWORD '${AUTHENTIK_DB_PASSWORD:-changeme_authentik}';
  CREATE DATABASE authentik OWNER authentik;

  -- Plane
  CREATE USER plane WITH PASSWORD '${PLANE_DB_PASSWORD:-changeme_plane}';
  CREATE DATABASE plane OWNER plane;

  -- Flexprice
  CREATE USER flexprice WITH PASSWORD '${FLEXPRICE_DB_PASSWORD:-changeme_flexprice}';
  CREATE DATABASE flexprice OWNER flexprice;
EOSQL

echo "✅ All databases created successfully."
