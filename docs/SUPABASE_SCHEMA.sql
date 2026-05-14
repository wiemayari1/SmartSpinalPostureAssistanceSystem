-- ============================================================
-- SpineGuard — Schéma Supabase PostgreSQL
-- ============================================================

-- Table principale des données posturales
CREATE TABLE IF NOT EXISTS posture_data (
  id              BIGSERIAL PRIMARY KEY,
  device_id       TEXT NOT NULL DEFAULT 'spineguard-001',
  posture_state   TEXT NOT NULL,
  pitch           NUMERIC(6,2),
  roll            NUMERIC(6,2),
  deviation       NUMERIC(6,2),
  total_alerts    INTEGER DEFAULT 0,
  bad_posture_time INTEGER DEFAULT 0,
  session_duration INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Table des alertes
CREATE TABLE IF NOT EXISTS alerts_log (
  id          BIGSERIAL PRIMARY KEY,
  device_id   TEXT NOT NULL DEFAULT 'spineguard-001',
  alert_type  TEXT NOT NULL,
  state       TEXT,
  pitch       NUMERIC(6,2),
  roll        NUMERIC(6,2),
  deviation   NUMERIC(6,2),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Vue résumé quotidien
CREATE OR REPLACE VIEW daily_summary AS
SELECT
  DATE(created_at) AS date,
  COUNT(*) AS total_records,
  AVG(deviation) AS avg_deviation,
  SUM(CASE WHEN posture_state IN ('bad','critical') THEN 1 ELSE 0 END) AS bad_count,
  MAX(total_alerts) AS max_alerts
FROM posture_data
GROUP BY DATE(created_at)
ORDER BY date DESC;
