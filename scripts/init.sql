-- ============================================================
-- GreenAIT — Initialisation du schéma PostgreSQL
-- ============================================================

-- Extension UUID
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- Clusters
-- Groupe logique de serveurs géré par l'admin.
-- L'UUID est distribué aux runners pour identifier le cluster.
-- ============================================================
CREATE TABLE IF NOT EXISTS clusters (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(128) NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Servers
-- Chaque serveur (simulé ou réel) appartient à un cluster.
-- L'UUID est le SERVER_ID passé au runner via env var.
-- ============================================================
CREATE TABLE IF NOT EXISTS servers (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    cluster_id  UUID         NOT NULL REFERENCES clusters(id) ON DELETE CASCADE,
    name        VARCHAR(128) NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ
);

-- ============================================================
-- Server Metrics (time-series)
-- Insérée à chaque step du runner (~toutes les 30s par serveur).
-- ============================================================
CREATE TABLE IF NOT EXISTS server_metrics (
    id             BIGSERIAL    PRIMARY KEY,
    server_id      UUID         NOT NULL REFERENCES servers(id) ON DELETE CASCADE,
    recorded_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    -- Contexte de simulation
    simulated_hour FLOAT        NOT NULL,
    incoming_load  FLOAT        NOT NULL,

    -- État du serveur
    powered_on     BOOLEAN      NOT NULL,
    eco_mode       BOOLEAN      NOT NULL,

    -- Métriques
    cpu_percent    FLOAT        NOT NULL,
    ram_percent    FLOAT        NOT NULL,
    disk_percent   FLOAT        NOT NULL,
    net_in_mbps    FLOAT        NOT NULL,
    net_out_mbps   FLOAT        NOT NULL,
    cpu_temp_c     FLOAT        NOT NULL,
    power_w        FLOAT        NOT NULL
);

-- Index pour les requêtes time-series (filtre par serveur + tri par date)
CREATE INDEX IF NOT EXISTS idx_metrics_server_time
    ON server_metrics(server_id, recorded_at DESC);

-- Index global sur recorded_at (agrégats multi-serveurs, Grafana, etc.)
CREATE INDEX IF NOT EXISTS idx_metrics_time
    ON server_metrics(recorded_at DESC);
