-- Phase 1: Archivregister -- Dokumentidentitaet, Versionen, Dateien, Relationen

create table documents (
  id uuid primary key default gen_random_uuid(),
  document_id text not null unique,
  canonical_id text not null,
  document_type text not null,
  category text,
  title text not null,
  canonical_language text not null default 'DE',
  lifecycle_status text not null default 'draft',
  evidence_profile text[] not null default '{}',
  repository_path text,
  canonical_url text,
  public boolean not null default false,
  content_owner text not null,
  metadata_owner text not null default 'SYS:KUEPER:knowledge-graph',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  published_at timestamptz,
  archived_at timestamptz,
  constraint documents_document_id_nonempty check (length(trim(document_id)) > 0),
  constraint documents_canonical_id_nonempty check (length(trim(canonical_id)) > 0)
);
-- Beispiele: DOC:KUE:KUE-SCI-0167-2026-DE / DOC:OTA:OTA-SCI-0083-2026-DE
-- document_id ist die systemweite stabile Referenz; die UUID bleibt technisch.

create table document_versions (
  id uuid primary key default gen_random_uuid(),
  document_id uuid not null references documents(id) on delete cascade,
  version text not null,
  language text not null,
  status text not null default 'draft',
  repository_path text not null,
  git_commit_sha text,
  content_hash text,
  frontmatter_hash text,
  title text not null,
  summary text,
  change_note text,
  is_current boolean not null default false,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  imported_at timestamptz not null default now(),
  published_at timestamptz,
  unique (document_id, version, language)
);
-- Version und Sprache getrennt: eine englische Fassung ist eine Sprachvariante
-- derselben stabilen Identitaet, kein eigenes Dokument.
-- Hinweis: bestehende IDs mit Sprach-/Jahresbestandteilen bleiben unangetastet;
-- document_id/canonical_id werden NICHT automatisch aus Einzelfeldern zusammengesetzt.

create table document_files (
  id uuid primary key default gen_random_uuid(),
  document_version_id uuid not null references document_versions(id) on delete cascade,
  file_role text not null,
  repository_path text not null,
  mime_type text,
  content_hash text,
  caption text,
  alt_text text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique (document_version_id, repository_path)
);
-- file_role z.B.: body, figure, diagram, dataset, attachment, bibliography,
-- source, cover, thumbnail. Wichtig fuer OTA-SCI-Dokumente mit Abbildungen.

create table document_relations (
  id uuid primary key default gen_random_uuid(),
  source_document_id uuid not null references documents(id) on delete cascade,
  relation_type text not null,
  target_document_id uuid references documents(id) on delete cascade,
  external_target_id text,
  rationale text,
  status text not null default 'confirmed',
  created_at timestamptz not null default now(),
  constraint exactly_one_relation_target check (
    (target_document_id is not null and external_target_id is null)
    or
    (target_document_id is null and external_target_id is not null)
  )
);
-- relation_type z.B.: supersedes, superseded_by, depends_on, extends,
-- summarizes, translates, references, contradicts, supports, derived_from,
-- applies, companion_to.
-- Unterschied zum Knowledge Graph: diese Tabelle haelt redaktionelle
-- Dokumentbeziehungen; das KG haelt globale Entitaetsidentitaeten und
-- projektuebergreifende Mappings.
