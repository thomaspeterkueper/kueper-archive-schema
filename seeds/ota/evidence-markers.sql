-- OTA-Evidenzprofil: R, H, T, S, I, F, OFFEN
insert into evidence_markers (code, label, description, sort_order) values
  ('R', 'Real/belegt', 'Empirisch oder durch anerkannte Quellen belegt', 1),
  ('H', 'Hypothese', 'Explizit als Hypothese markiert', 2),
  ('T', 'Theorie', 'Etablierte wissenschaftliche Theorie', 3),
  ('S', 'Spekulativ', 'Plausible, aber unbelegte Erweiterung', 4),
  ('I', 'Illustrativ', 'Beispielhaft, nicht als Tatsachenbehauptung gemeint', 5),
  ('F', 'Fiktion', 'In-universe-Kanon, kein Realitaetsanspruch', 6),
  ('OFFEN', 'Offen', 'Noch nicht klassifiziert', 7);
