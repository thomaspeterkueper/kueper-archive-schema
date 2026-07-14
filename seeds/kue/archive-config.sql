insert into archive_config (
  archive_code, archive_name, system_id, document_id_prefix,
  repository_full_name, default_branch, content_root,
  canonical_base_url, schema_version
) values (
  'KUE',
  'kueper.com',
  'SYS:KUEPER:kueper-com',
  'DOC:KUE:',
  'thomaspeterkueper/kueper.com',
  'main',
  'src/content/kue',
  'https://kueper.com',
  '1.0.0'
);
