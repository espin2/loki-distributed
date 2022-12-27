auth_enabled: false

server:
  log_level: info
  http_listen_port: {{ env "NOMAD_PORT_http" }}
  grpc_listen_port: {{ env "NOMAD_PORT_grpc" }}
  http_server_read_timeout: 300s
  http_server_write_timeout: 300s
  http_server_idle_timeout: 300s

common:
  replication_factor: 2
  instance_addr: {{ env "NOMAD_IP_grpc" }}

  ring:
    instance_availability_zone: {{ env "node.unique.name" }}
    zone_awareness_enabled: true
    instance_addr: {{ env "NOMAD_IP_grpc" }}
    kvstore:
      store: consul
      prefix: loki/
      consul:
        host: {{ env "attr.unique.network.ip-address" }}:8500

ingester:
  chunk_idle_period: 30m
  chunk_retain_period: 0s
  chunk_block_size: 262144
  chunk_encoding: snappy
  chunk_target_size: 1572864
  max_chunk_age: 1h
  max_transfer_retries: 0
  wal:
    enabled: false


frontend:
  compress_responses: true
  log_queries_longer_than: 5s
  scheduler_address: loki-query-scheduler.service.consul:9096


frontend_worker:
  frontend_address: loki-query-frontend.service.consul:9096


schema_config:
  configs:
  - from: 2022-05-15
    store: boltdb-shipper
    object_store: aws
    schema: v12
    index:
      prefix: index_
      period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: {{ env "NOMAD_ALLOC_DIR" }}/data/index
    cache_location: {{ env "NOMAD_ALLOC_DIR" }}/data/index-cache
    shared_store: s3
    index_gateway_client:
      server_address: loki-index-gateway.service.consul:9097

  aws:
    bucketnames: efishery-loki
    region: ap-southeast-1
    access_key_id: ${S3_ACCESS_KEY_ID}
    secret_access_key: ${S3_SECRET_ACCESS_KEY}
    s3forcepathstyle: true

compactor:
  working_directory: {{ env "NOMAD_ALLOC_DIR" }}/compactor
  shared_store: s3
  retention_enabled: true
  compaction_interval: 10m
  retention_delete_delay: 2h
  retention_delete_worker_count: 150

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
  max_cache_freshness_per_query: 10m
  max_global_streams_per_user: 0
  max_query_length: 721h
  max_query_parallelism: 32
  max_query_series: 5000
  max_streams_per_user: 0
  retention_period: 744h
  per_stream_rate_limit: 10MB
  per_stream_rate_limit_burst: 20MB
  ingestion_rate_strategy: global
  ingestion_rate_mb: 60
  ingestion_burst_size_mb: 20
  split_queries_by_interval: 30m

chunk_store_config:
  max_look_back_period: 0s
  chunk_cache_config:
    enable_fifocache: true
    fifocache:
      max_size_bytes: 500MB

query_range:
  align_queries_with_step: true
  max_retries: 5
  cache_results: true
  results_cache:
    cache:
      enable_fifocache: true
      fifocache:
        max_size_items: 1024
        validity: 24h
querier:
  max_concurrent: 20
  query_timeout: 5m
