-- Phase 4: Synchronisation mit GitHub
-- Sicherheitsleitplanke: direction beginnt ausschliesslich als
-- 'github_to_database'. Eine kontrollierte Gegenrichtung
-- ('database_to_branch') kann spaeter folgen, aber NIEMALS
-- 'database_to_main' -- die Datenbank wird nicht zur Schreibquelle fuer
-- den Hauptbranch (siehe ECO-ARC-0013, verbindlich).

create table sync_runs (
  id uuid primary key default gen_random_uuid(),
  direction text not null,
  trigger_type text not null,
  repository_full_name text not null,
  branch text not null,
  commit_sha text,
  status text not null,
  documents_found integer not null default 0,
  documents_created integer not null default 0,
  documents_updated integer not null default 0,
  errors_count integer not null default 0,
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  error_summary text
);

create table sync_events (
  id uuid primary key default gen_random_uuid(),
  sync_run_id uuid not null references sync_runs(id) on delete cascade,
  event_type text not null,
  severity text not null default 'info',
  document_id text,
  repository_path text,
  message text not null,
  payload jsonb not null default '{}',
  created_at timestamptz not null default now()
);
