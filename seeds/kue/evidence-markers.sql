-- KUE-Evidenzprofil: R, T, S, P, H, I
insert into evidence_markers (code, label, description, sort_order) values
  ('R', 'Real/belegt', 'Empirisch oder durch anerkannte Quellen belegt', 1),
  ('T', 'Theorie', 'Etablierte wissenschaftliche Theorie', 2),
  ('S', 'Spekulativ', 'Plausible, aber unbelegte Erweiterung', 3),
  ('P', 'Perspektive', 'Standpunkt-/Interpretationsaussage', 4),
  ('H', 'Hypothese', 'Explizit als Hypothese markiert', 5),
  ('I', 'Illustrativ', 'Beispielhaft, nicht als Tatsachenbehauptung gemeint', 6);
