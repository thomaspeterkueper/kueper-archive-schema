-- Phase 2: Redaktion -- Requests, Work Items, Review, Publication Checks
-- requests spiegelt External Tasks, ersetzt sie aber nicht.

create table requests (
  id uuid primary key default gen_random_uuid(),
  external_task_id text unique,
  source_system text,
  target_system text,
  request_type text not null,
  title text not null,
  priority text not null default 'medium',
  status text not null default 'received',
  repository_path text,
  github_issue_number integer,
  requested_at date,
  classified_at timestamptz,
  completed_at timestamptz,
  result_document_id uuid references documents(id),
  decision_summary text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
-- request_type z.B.: reference, foundation, review, correction, publication,
-- mapping, legal, architecture.
-- status z.B.: received, classified, planned, in_progress, blocked, review,
-- done, rejected, superseded.

create table work_items (
  id uuid primary key default gen_random_uuid(),
  request_id uuid references requests(id) on delete set null,
  document_id uuid references documents(id) on delete cascade,
  work_type text not null,
  title text not null,
  status text not null default 'open',
  priority text not null default 'medium',
  assigned_to uuid,
  due_at timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz
);
-- work_type z.B.: draft, review, source_check, claim_check, translation,
-- metadata, illustration, publication, correction, migration.

create table review_decisions (
  id uuid primary key default gen_random_uuid(),
  document_version_id uuid references document_versions(id) on delete cascade,
  request_id uuid references requests(id) on delete cascade,
  decision_type text not null,
  decision text not null,
  rationale text,
  decided_by uuid,
  decided_at timestamptz not null default now()
);

create table publication_checks (
  id uuid primary key default gen_random_uuid(),
  document_version_id uuid not null references document_versions(id) on delete cascade,
  check_code text not null,
  status text not null,
  message text,
  checked_at timestamptz not null default now(),
  resolved_at timestamptz,
  unique (document_version_id, check_code)
);
-- check_code Beispiele: STABLE_ID_PRESENT, FRONTMATTER_VALID,
-- SOURCES_RESOLVED, CLAIMS_CLASSIFIED, KG_METADATA_PRESENT, ASSETS_PRESENT,
-- CANONICAL_URL_VALID, TRANSLATION_LINKED, LEGAL_RELEASED,
-- NO_UNRESOLVED_PLACEHOLDERS.
