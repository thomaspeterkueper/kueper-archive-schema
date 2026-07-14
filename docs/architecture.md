# Architektur — KUEPER Archive Core

Vollständige Herleitung und Entscheidung: `kueper-ecosystem/decisions/ECO-ARC-0013-2026-DE.md`.
Dieses Dokument fasst die Struktur zusammen.

## Grundprinzip

Ein Datenmodell, zwei physisch getrennte Supabase-Projekte (KUE, OTA). Keine
gemeinsame Datenbank mit `tenant_id`. Vorteile: klare Source-of-Truth-Grenzen,
unabhängige Backups, keine versehentliche Vermischung, getrennte Service-Keys,
getrennte Deployment-/Importzyklen, spätere Erweiterbarkeit für weitere
Archive, kein Mandanten-Filter in jeder Abfrage.

## Schicht 1 — Kanonische Dokumentidentität

`documents` (stabile `document_id`, kein Volltext) → `document_versions`
(Version × Sprache getrennt) → `document_files` (Rollen: body, figure,
diagram, dataset, attachment, bibliography, source, cover, thumbnail) →
`document_relations` (redaktionelle Beziehungen — nicht zu verwechseln mit
den globalen Entitätsmappings des Knowledge Graph).

## Schicht 2 — Inhaltliche Nachweise

`claims` (mit `claim_type`: factual, derived, hypothesis, interpretation,
prediction, definition, fictional_canon, editorial) ↔ `evidence_markers`
(konfigurierbar statt Enum, siehe `seeds/kue/` vs. `seeds/ota/` für die
unterschiedlichen Profile) → `document_claims` (Verortung im Dokument) ↔
`sources` ↔ `claim_sources`.

## Schicht 3 — Redaktion und Workflow

`requests` spiegelt External Tasks (verknüpft über `external_task_id`),
ersetzt sie aber nicht. `work_items`, `review_decisions`,
`publication_checks` (u. a. `STABLE_ID_PRESENT`, `SOURCES_RESOLVED`,
`KG_METADATA_PRESENT`, `LEGAL_RELEASED`, `NO_UNRESOLVED_PLACEHOLDERS`).

## Schicht 4 — Suche und Synchronisation

`document_sections` (Volltextsuche je Abschnitt) + `search_embeddings`
(regenerierbar, keine kanonischen Daten) + `sync_runs`/`sync_events`
(GitHub-Synchronisation).

**Leitplanke:** `sync_runs.direction` beginnt ausschließlich als
`github_to_database`. `database_to_main` ist niemals zulässig.

## Was konfiguriert wird

| Bereich | KUE | OTA |
|---|---|---|
| Archivcode | `KUE` | `OTA` |
| System-ID | `SYS:KUEPER:kueper-com` | `SYS:KUEPER:ota` |
| ID-Präfix | `DOC:KUE:` | `DOC:OTA:` |
| Repository | `kueper.com` | `overtime-archive.org` |
| Default Branch | `main` | `master` |
| Evidenzmarker | R,T,S,P,H,I | R,H,T,S,I,F,OFFEN |
| Inhaltlicher Scope | Grundlagen/Publikationen | Forschungs-/Archivdokumente |

## Umsetzungsphasen

1. **Archivregister** (`archive_config`, `documents`, `document_versions`,
   `document_files`, `document_relations`, `sync_runs`, `sync_events`) —
   Migrationen 0001–0002, 0005.
2. **Redaktion** (`requests`, `work_items`, `review_decisions`,
   `publication_checks`) — Migration 0004.
3. **Wissensnachweise** (`claims`, `sources`, `claim_sources`,
   `document_claims`, `document_sections`, `search_embeddings`) —
   Migrationen 0003, 0006.

Benutzer/RLS (Migration 0007) ist Voraussetzung für jede Phase, bei der
Schreibzugriff über Supabase Auth erfolgt.

## Bewusst ausgelassen in V1

Kollaboratives Echtzeit-Editing, Speicherung des vollständigen Markdowntexts
in der DB, automatische KI-Änderungen an Dokumenten, automatische
Veröffentlichungen, öffentliche Benutzerkonten, Kommentare, feingranulare
Teams/Organisationen, Datenbank als Schreibquelle für `main`, vollautomatische
globale Claim-IDs ohne KG-Abstimmung.

## Offene Punkte

- RLS-Policies sind in Migration 0007 nur als TODO markiert, nicht ausformuliert.
- Sprachabhängige Volltextsuche (aktuell fest `german`).
- Konkreter Zeitpunkt der produktiven Anwendung auf KUE bzw. OTA.
