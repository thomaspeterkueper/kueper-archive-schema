-- Schliesst den TODO aus 0007_users_rls.sql: RLS aktivieren UND durchsetzen,
-- nicht nur das Rollenmodell anlegen. Ohne diese Migration bleiben Tabellen
-- ueber die Supabase Data API (PostgREST) potenziell offen zugaenglich.
--
-- Modell: aktuell administriert ausschliesslich der Owner (role = 'owner').
-- Alle redaktionellen Tabellen: voller Zugriff fuer 'owner', kein Zugriff
-- fuer alle anderen (kein 'anon', kein 'authenticated' ohne Owner-Rolle).
-- Erweiterung um 'editor'/'reviewer'/'viewer' folgt erst, wenn tatsaechlich
-- mehrere Personen administrieren (siehe README, "Nicht entschieden").

-- Hilfsfunktion: ist der aktuelle Nutzer Owner?
create or replace function is_owner()
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from user_roles
    where user_id = auth.uid() and role = 'owner'
  );
$$;

-- RLS aktivieren
alter table archive_config enable row level security;
alter table documents enable row level security;
alter table document_versions enable row level security;
alter table document_files enable row level security;
alter table document_relations enable row level security;
alter table claims enable row level security;
alter table evidence_markers enable row level security;
alter table document_claims enable row level security;
alter table sources enable row level security;
alter table claim_sources enable row level security;
alter table requests enable row level security;
alter table work_items enable row level security;
alter table review_decisions enable row level security;
alter table publication_checks enable row level security;
alter table sync_runs enable row level security;
alter table sync_events enable row level security;
alter table document_sections enable row level security;
alter table search_embeddings enable row level security;
alter table profiles enable row level security;
alter table user_roles enable row level security;

-- Owner: voller Zugriff auf alle redaktionellen Tabellen.
create policy owner_full_access on archive_config for all using (is_owner()) with check (is_owner());
create policy owner_full_access on documents for all using (is_owner()) with check (is_owner());
create policy owner_full_access on document_versions for all using (is_owner()) with check (is_owner());
create policy owner_full_access on document_files for all using (is_owner()) with check (is_owner());
create policy owner_full_access on document_relations for all using (is_owner()) with check (is_owner());
create policy owner_full_access on claims for all using (is_owner()) with check (is_owner());
create policy owner_full_access on evidence_markers for all using (is_owner()) with check (is_owner());
create policy owner_full_access on document_claims for all using (is_owner()) with check (is_owner());
create policy owner_full_access on sources for all using (is_owner()) with check (is_owner());
create policy owner_full_access on claim_sources for all using (is_owner()) with check (is_owner());
create policy owner_full_access on requests for all using (is_owner()) with check (is_owner());
create policy owner_full_access on work_items for all using (is_owner()) with check (is_owner());
create policy owner_full_access on review_decisions for all using (is_owner()) with check (is_owner());
create policy owner_full_access on publication_checks for all using (is_owner()) with check (is_owner());
create policy owner_full_access on sync_runs for all using (is_owner()) with check (is_owner());
create policy owner_full_access on sync_events for all using (is_owner()) with check (is_owner());
create policy owner_full_access on document_sections for all using (is_owner()) with check (is_owner());
create policy owner_full_access on search_embeddings for all using (is_owner()) with check (is_owner());

-- profiles: jeder sieht/bearbeitet nur sich selbst, Owner sieht alle.
create policy self_or_owner_select on profiles for select using (id = auth.uid() or is_owner());
create policy self_update on profiles for update using (id = auth.uid()) with check (id = auth.uid());
create policy owner_manage_roles on user_roles for all using (is_owner()) with check (is_owner());

-- Kein Zugriff fuer 'anon'. Die oeffentliche Website liest ueber den beim
-- Build aus GitHub erzeugten Content, nicht direkt aus Supabase (siehe
-- README). Falls spaeter eine begrenzte oeffentliche Read-API gewuenscht
-- ist, dafuer eine eigene, bewusst eingeschraenkte Policy ergaenzen -- nicht
-- die owner_full_access-Policies aufweichen.
