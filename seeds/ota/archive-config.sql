insert into archive_config (
  archive_code, archive_name, system_id, document_id_prefix,
  repository_full_name, default_branch, content_root,
  canonical_base_url, schema_version
) values (
  'OTA',
  'OverTime Archive',
  'SYS:KUEPER:ota',
  'DOC:OTA:',
  'thomaspeterkueper/overtime-archive.org',
  'master',
  'src/content/documents',
  'https://overtime-archive.org',
  '1.0.0'
);
