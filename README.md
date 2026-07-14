# KUEPER Archive Core

Gemeinsames Datenbankschema (Migrationen, Typdefinitionen, Importer,
Validatoren) für kanonische Dokumentarchive im KUEPER-Ökosystem.

**Ein Datenmodell, ein gemeinsames Supabase-Projekt (`kue-archive`),
getrennte Postgres-Schemas:** `kueper.com` (Code `KUE`, Namespace
`DOC:KUE:*`) liegt in `public`, `overtime-archive.org` (Code `OTA`, Namespace
`DOC:OTA:*`) in einem eigenen Schema `ota`. Beide verwenden identische
Migrationen, RLS-Policies, Import-/Validierungslogik und
Suchindexstruktur. Keine gemeinsame Datenbank mit `tenant_id`-Spalte — die
Trennung erfolgt über Postgres-Schemas, nicht über eine Mandantenspalte in
jeder Zeile.

**Korrektur vom 2026-07-14:** Ursprünglich waren zwei physisch getrennte
Supabase-Projekte vorgesehen (siehe `git log` / ECO-ARC-0013). Aus
Kostengründen (10$ statt 20$/Monat) teilen sich beide Archive nun ein
Projekt. Owner-Verwaltung (`profiles`, `user_roles`, `is_owner()`) bleibt
dabei einmalig zentral, nicht pro Schema dupliziert — siehe
[`docs/apply-second-archive-schema.md`](docs/apply-second-archive-schema.md).

## Rolle im Ökosystem

Dieses Repository gehört weder `kueper.com` noch `overtime-archive.org`
allein — beide sind gleichberechtigte Konsumenten. Ökosystem-Code: `ARCH`,
Rolle: `infrastructure`. Details und Begründung:
[`decisions/ECO-ARC-0013-2026-DE.md`](https://github.com/thomaspeterkueper/kueper-ecosystem/blob/main/decisions/ECO-ARC-0013-2026-DE.md)
im Repository `kueper-ecosystem`.

## Status

1. Schema V1 dokumentiert. ✅
2. Zuständigkeit geklärt. ✅ (ECO-ARC-0013)
3. Migrationen angelegt. ✅
4. KUE (`public`-Schema in `kue-archive`) angewendet und produktiv. ✅
   (Supabase Free Tier, Organisation Kueper-Archives, Frankfurt)
5. OTA (`ota`-Schema in **demselben** Projekt `kue-archive`) — offen, siehe
   [`docs/apply-second-archive-schema.md`](docs/apply-second-archive-schema.md).

## Struktur

```text
migrations/   Gemeinsame SQL-Migrationen, phasenweise (0001–0008)
seeds/kue/    Seed-Daten für die KUE-Instanz (archive_config, evidence_markers)
seeds/ota/    Seed-Daten für die OTA-Instanz
docs/         Architekturdokumentation
```

## Vier Schichten

1. **Kanonische Dokumentidentität** — `documents`, `document_versions`,
   `document_files`, `document_relations`
2. **Inhaltliche Nachweise** — `claims`, `sources`, `claim_sources`,
   `document_claims`
3. **Redaktion und Workflow** — `requests`, `work_items`,
   `review_decisions`, `publication_checks`
4. **Suche und Synchronisation** — `document_sections`, `search_embeddings`,
   `sync_runs`, `sync_events`

Details je Schicht: [`docs/architecture.md`](docs/architecture.md).

## Was identisch bleibt vs. konfiguriert wird

Identisch: Tabellen, Migrationen, RLS, Import-/Validierungslogik,
Sync-Protokoll, Admin-Oberfläche, Quellen-/Claim-Modell, Request-Workflow,
Suchindexstruktur.

Konfiguriert (nur `archive_config`): Archivcode, System-ID, ID-Präfix,
Repository, Dokumentklassen, Evidenzmarker-Profil, kanonische URL,
inhaltlicher Scope. Siehe `seeds/kue/` und `seeds/ota/`.

## Sicherheitsleitplanke

`sync_runs.direction` beginnt ausschließlich als `github_to_database`. Eine
kontrollierte Gegenrichtung (`database_to_branch`) kann später folgen, aber
**niemals** `database_to_main` — die Datenbank wird nicht zur Schreibquelle
für den Hauptbranch.

## Verbindliche Ökosystem-Regeln

**[`kueper-ecosystem/docs/onboarding-template.md`](https://github.com/thomaspeterkueper/kueper-ecosystem/blob/main/docs/onboarding-template.md)**

## Cross-Repository-Anforderungen

Änderungswünsche liegen als External Task unter `external-tasks/open/`.
Format: [`ECO-ARC-0006`](https://github.com/thomaspeterkueper/kueper-ecosystem/blob/main/decisions/ECO-ARC-0006-2026-DE.md).

## GitHub-Integration (Supabase)

`kue-archive` hat dieses Repository als GitHub-Quelle hinterlegt. Solange
hier **kein** `supabase/`-Ordner existiert und „Deploy to production" nicht
aktiv ist, löst das keinen automatischen Deploy aus — die Verknüpfung ist
aktuell passiv. Migrationen werden während der Testphase bewusst **manuell**
über den SQL-Editor eingespielt (siehe Umsetzungsplan, ECO-ARC-0013).

Grund für die Zurückhaltung: Dieses Repository bedient perspektivisch zwei
Datenbanken (KUE, später OTA), Supabase's GitHub-Integration ist aber auf
ein Repo → ein Projekt ausgelegt. Eine echte CI/CD-Anbindung braucht daher
erst eine bewusste Strukturentscheidung (`supabase/`-Ordner, ggf. getrennte
Branches oder Repos je Instanz) — nicht vor Abschluss der KUE-Testphase.
