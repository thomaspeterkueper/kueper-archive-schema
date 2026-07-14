-- Phase 3: Wissensnachweise -- Claims, Evidenzmarker, Quellen

create table claims (
  id uuid primary key default gen_random_uuid(),
  claim_id text unique,
  statement text not null,
  normalized_statement text,
  claim_type text not null default 'factual',
  evidence_status text not null,
  confidence numeric(4,3),
  scope_note text,
  valid_from date,
  valid_until date,
  superseded_by uuid references claims(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
-- claim_type z.B.: factual, derived, hypothesis, interpretation, prediction,
-- definition, fictional_canon, editorial.
-- KUE und OTA nutzen dieselbe Struktur, aber unterschiedliche Evidenzprofile
-- (Beispiel KUE: R,T,S,P,H,I -- Beispiel OTA: R,H,T,S,I,F,OFFEN).

create table evidence_markers (
  code text primary key,
  label text not null,
  description text not null,
  sort_order integer not null,
  active boolean not null default true
);
-- Konfigurierbare Referenztabelle statt starrem Postgres-Enum, damit KUE und
-- OTA unterschiedliche Markerprofile fahren koennen (siehe seeds/).

create table document_claims (
  id uuid primary key default gen_random_uuid(),
  document_version_id uuid not null references document_versions(id) on delete cascade,
  claim_id uuid not null references claims(id) on delete cascade,
  marker_code text references evidence_markers(code),
  section_anchor text,
  quotation text,
  editorial_note text,
  sort_order integer not null default 0,
  unique (document_version_id, claim_id, section_anchor)
);

create table sources (
  id uuid primary key default gen_random_uuid(),
  source_id text unique,
  source_type text not null,
  title text not null,
  authors text[] not null default '{}',
  publisher text,
  publication_year integer,
  doi text,
  isbn text,
  url text,
  repository_url text,
  accessed_at date,
  publication_date date,
  citation_text text,
  metadata jsonb not null default '{}',
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
-- source_type z.B.: paper, book, dataset, website, standard, report,
-- archive_document, primary_source, internal_document, software, observation.

create table claim_sources (
  id uuid primary key default gen_random_uuid(),
  claim_id uuid not null references claims(id) on delete cascade,
  source_id uuid not null references sources(id) on delete cascade,
  support_type text not null default 'supports',
  locator text,
  quotation text,
  note text,
  created_at timestamptz not null default now(),
  unique (claim_id, source_id, locator)
);
-- support_type z.B.: supports, contradicts, contextualizes, derives,
-- mentions, external_anchor.
