# Zweites Archiv im selben Projekt: OTA-Schema in `kue-archive`

Owner-Entscheidung (2026-07-14, Korrektur der ursprünglichen
Zwei-Projekte-Architektur): Aus Kostengründen teilen sich KUE und OTA **ein**
Supabase-Projekt (`kue-archive`). Getrennt bleiben die **Postgres-Schemas**,
nicht die Projekte: KUE liegt in `public` (bereits angewendet), OTA bekommt
ein eigenes Schema `ota`.

**Wichtig:** Owner-Verwaltung (`profiles`, `user_roles`, `is_owner()`) bleibt
**einmalig und zentral** in `public` — sie wird für `ota` nicht dupliziert.
Es gibt weiterhin nur einen Owner (dich), unabhängig davon, wie viele
Archiv-Schemas es gibt. Nur die eigentlichen Inhaltstabellen (Migrationen
`0001`–`0006`) werden pro Archiv getrennt gehalten.

## Reihenfolge

Migrationen `0007` (Rollenmodell) und `0008` (RLS-Policies) sind bereits
einmalig über `0001`–`0006` in `public` angewendet (KUE). Für OTA **nicht**
erneut ausführen — stattdessen:

### 1. Schema anlegen und aktivieren

```sql
create schema if not exists ota;
set search_path to ota, public;
```

`public` bleibt im Suchpfad, damit z. B. der `vector`-Typ (aus der bereits
installierten pgvector-Extension) und `public.is_owner()` auffindbar sind.

### 2. Inhaltstabellen anwenden (0001–0006, unverändert)

Migrationen `0001_archive_config.sql` bis `0006_search.sql` **genau wie bei
KUE** ausführen. Durch den gesetzten `search_path` landen alle Tabellen
automatisch in `ota.*` statt `public.*` — die SQL-Dateien selbst bleiben
unverändert (kein Schema-Präfix im Dateiinhalt nötig).

Hinweis zu `0006`: `create extension if not exists vector;` ist idempotent —
die Extension ist bereits installiert, der Befehl tut dann nichts. Der
`vector`-Typ selbst ist über `public` im Suchpfad weiterhin sichtbar.

### 3. RLS auf die OTA-Tabellen anwenden — mit geteiltem `is_owner()`

**Nicht** `0008_rls_policies.sql` unverändert erneut laufen lassen (das würde
`is_owner()` und die Policies nochmal in `ota` anlegen). Stattdessen:

```sql
alter table ota.archive_config enable row level security;
alter table ota.documents enable row level security;
alter table ota.document_versions enable row level security;
alter table ota.document_files enable row level security;
alter table ota.document_relations enable row level security;
alter table ota.claims enable row level security;
alter table ota.evidence_markers enable row level security;
alter table ota.document_claims enable row level security;
alter table ota.sources enable row level security;
alter table ota.claim_sources enable row level security;
alter table ota.requests enable row level security;
alter table ota.work_items enable row level security;
alter table ota.review_decisions enable row level security;
alter table ota.publication_checks enable row level security;
alter table ota.sync_runs enable row level security;
alter table ota.sync_events enable row level security;
alter table ota.document_sections enable row level security;
alter table ota.search_embeddings enable row level security;

create policy owner_full_access on ota.archive_config for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.documents for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.document_versions for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.document_files for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.document_relations for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.claims for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.evidence_markers for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.document_claims for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.sources for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.claim_sources for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.requests for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.work_items for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.review_decisions for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.publication_checks for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.sync_runs for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.sync_events for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.document_sections for all using (public.is_owner()) with check (public.is_owner());
create policy owner_full_access on ota.search_embeddings for all using (public.is_owner()) with check (public.is_owner());
```

### 4. Seeds einspielen

```sql
set search_path to ota, public;
```

Danach `seeds/ota/archive-config.sql` und `seeds/ota/evidence-markers.sql`
ausführen (Inhalt unverändert — landet dank `search_path` automatisch in
`ota.archive_config` bzw. `ota.evidence_markers`).

### 5. Suchpfad zurücksetzen

```sql
set search_path to public;
```

Nicht vergessen — sonst landen künftige, eigentlich für KUE gedachte Befehle
versehentlich im `ota`-Schema.

### 6. Data API: Schema exponieren

Supabase exponiert über die Data API standardmäßig nur `public`. Damit eine
künftige Anwendung `ota.*` über die REST-API ansprechen kann: Dashboard →
Settings → API → **Exposed schemas** → `ota` ergänzen.

## Was NICHT dupliziert wird

- `profiles`, `user_roles`, `is_owner()` — bleiben einmalig in `public`.
- pgvector-Extension — einmalig auf Projektebene installiert.

## Was getrennt bleibt

- Alle Inhaltstabellen aus `0001`–`0006` — vollständig getrennt je Schema
  (`public.*` für KUE, `ota.*` für OTA), inklusive eigener `archive_config`
  und eigenem Evidenzmarker-Profil.
