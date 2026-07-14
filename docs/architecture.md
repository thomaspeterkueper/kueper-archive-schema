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

Benutzer/RLS (Migrationen 0007 + 0008) ist Voraussetzung für jede Phase, bei
der Schreibzugriff über Supabase Auth erfolgt. RLS wird von Anfang an
aktiviert, nicht nachträglich ergänzt — insbesondere weil Supabase für neue
Projekte ab 30.05.2026 explizite Postgres-Grants für die Data API voraussetzt.

## Bewusst ausgelassen in V1

Kollaboratives Echtzeit-Editing, Speicherung des vollständigen Markdowntexts
in der DB, automatische KI-Änderungen an Dokumenten, automatische
Veröffentlichungen, öffentliche Benutzerkonten, Kommentare, feingranulare
Teams/Organisationen, Datenbank als Schreibquelle für `main`, vollautomatische
globale Claim-IDs ohne KG-Abstimmung.

## Namenskonvention für Supabase-Projekte

Nirgends im Ökosystem war bisher ein Namensschema für den Supabase-
Anzeigenamen dokumentiert (`noxiagame` und `solarsciencefoundation`
referenzieren nur ihre zufällige Projekt-Ref-ID). Für Archive Core gilt ab
sofort:

```text
{archive_code}-archive
```

Also `kue-archive` für KUE, `ota-archive` für OTA — passend zum jeweiligen
`archive_code` in `seeds/*/archive-config.sql`. Der Name hat keine technische
Funktion (Supabase nutzt intern ohnehin die Projekt-Ref-ID), dient aber der
eindeutigen Wiedererkennbarkeit der beiden zusammengehörigen Projekte im
Dashboard.

## Offene Punkte

- Sprachabhängige Volltextsuche (aktuell fest `german`).
- Konkreter Zeitpunkt der produktiven Anwendung auf OTA (KUE läuft, siehe
  Umsetzungsplan).
- Erweiterung des Rollenmodells über `owner`-only hinaus (editor/reviewer/
  viewer), sobald mehr als eine Person administriert.

## Kosten & Tier-Strategie

Owner-Entscheidung (2026-07-14): Beide Archiv-Datenbanken starten auf dem
**Supabase Free Tier** (Stand Juli 2026: 2 kostenlose Projekte pro
Organisation, keine Kreditkarte nötig, kommerzielle Nutzung erlaubt).

Begründung: Die Archiv-DBs sind reine Redaktions-/Admin-Werkzeuge (siehe
README: „Die öffentliche Website benötigt keinen direkten Supabase-Zugang").
Es gibt keinen Live-Traffic echter Endnutzer, der durch eine
Inaktivitätspause gestört würde.

**Tradeoff:** Free-Tier-Projekte pausieren nach 7 Tagen ohne
Datenbankaktivität automatisch (Daten bleiben erhalten, Reaktivierung per
Dashboard-Klick, ca. 30 Sekunden). Für OTA (aufgeschoben, überwiegend
inaktiv) ist das unproblematisch. Für KUE (aktiver Testbetrieb) kann es
zwischen Redaktionssitzungen zu Pausen kommen — kein Datenverlust, nur
manuelle Reaktivierung nötig.

**Wann auf Pro upgraden** ($10–25/Monat je nach Org-Plan): sobald die Pause
im Alltag störend wird, echte Backups gebraucht werden (Free Tier hat keine
automatischen Backups), oder die 500-MB-Datenbankgrenze erreicht wird.
Upgrade-Entscheidung pro Projekt einzeln, nicht zwingend beide gleichzeitig.

**Voraussetzung:** 2 freie Projekt-Slots in der Supabase-Organisation. Falls
bestehende Projekte (NOXIA, SSF, noxia-universe) diese bereits belegen, ist
das vor Anlage zu prüfen (Supabase Dashboard → Organisationseinstellungen).
