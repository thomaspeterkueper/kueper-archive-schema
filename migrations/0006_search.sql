-- Phase 4: Volltext und semantische Suche
-- Hinweis: to_tsvector('german', ...) ist fest verdrahtet und deckt keine
-- englischen Dokumente ab. Mittelfristig: Triggerfunktion, die je nach
-- Dokumentsprache 'german', 'english' oder 'simple' waehlt (offener Punkt,
-- siehe ECO-ARC-0013, Abschnitt "Nicht entschieden").

create table document_sections (
  id uuid primary key default gen_random_uuid(),
  document_version_id uuid not null references document_versions(id) on delete cascade,
  section_anchor text not null,
  heading text,
  section_level integer,
  position integer not null,
  content_text text not null,
  content_hash text not null,
  search_vector tsvector generated always as (
    to_tsvector('german', coalesce(heading, '') || ' ' || content_text)
  ) stored,
  unique (document_version_id, section_anchor)
);

create table search_embeddings (
  id uuid primary key default gen_random_uuid(),
  document_section_id uuid not null references document_sections(id) on delete cascade,
  model text not null,
  dimensions integer not null,
  embedding vector,
  content_hash text not null,
  created_at timestamptz not null default now(),
  unique (document_section_id, model)
);
-- Embeddings sind vollstaendig regenerierbare Indizes, keine kanonischen
-- Archivdaten. Erfordert die pgvector-Extension.
