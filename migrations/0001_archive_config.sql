-- Phase 1: Archivregister
-- Jede Datenbank (KUE oder OTA) enthaelt genau einen aktiven Archivdatensatz.
-- Konfiguration, keine Mandantenstruktur -- siehe README.md und
-- kueper-ecosystem/decisions/ECO-ARC-0013-2026-DE.md.

create table archive_config (
  id uuid primary key default gen_random_uuid(),
  archive_code text not null unique,
  archive_name text not null,
  system_id text not null unique,
  document_id_prefix text not null,
  repository_full_name text not null,
  default_branch text not null default 'main',
  content_root text not null,
  canonical_base_url text,
  schema_version text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
