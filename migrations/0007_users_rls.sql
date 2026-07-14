-- Benutzer und Rechte -- minimales Profilmodell, identisch fuer KUE und OTA.
-- Alle redaktionellen Tabellen mit RLS schuetzen, zunaechst nur 'owner'
-- zulassen. Die oeffentliche Website benoetigt keinen direkten
-- Supabase-Zugang: oeffentlich sichtbare Daten werden beim Build aus GitHub
-- erzeugt oder spaeter ueber eine bewusst begrenzte Read-API bereitgestellt.

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now()
);

create table user_roles (
  user_id uuid not null references profiles(id) on delete cascade,
  role text not null,
  primary key (user_id, role)
);
-- Rollen: owner, editor, reviewer, viewer.
--
-- Die tatsaechlichen RLS-Policies (Owner-only-Zugriff auf alle
-- redaktionellen Tabellen) stehen in 0008_rls_policies.sql. Diese Migration
-- (0007) legt nur das Rollenmodell an; ohne 0008 bleiben die Tabellen ohne
-- RLS-Durchsetzung. Beide Migrationen gehoeren zusammen angewendet.
