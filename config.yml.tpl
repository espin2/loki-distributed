auth_enabled: false
server:
  http_listen_port: 3100
distributor:
  ring:
    kvstore:
      store: memberlist
memberlist:
  join_members:
    - loki-memberlist
ingester:
  lifecycler:
    ring:
      kvstore:
        store: memberlist
      replication_factor: 1
  chunk_idle_period: 30m
  chunk_block_size: 262144
  chunk_encoding: snappy
  chunk_retain_period: 1m
  max_transfer_retries: 0
  wal:
    dir: /local/loki/wal
limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
  max_cache_freshness_per_query: 10m
  split_queries_by_interval: 15m
schema_config:
  configs:
  - from: 2020-09-07
    store: boltdb-shipper
    object_store: filesystem
    schema: v11
    index:
      prefix: loki_index_
      period: 24h
storage_config:
  boltdb_shipper:
    shared_store: filesystem
    active_index_directory: /local/loki/index
    cache_location: /local/loki/cache
    cache_ttl: 168h
  filesystem:
    directory: /local/loki/chunks
query_range:
  align_queries_with_step: true
  max_retries: 5
  cache_results: true
  results_cache:
    cache:
      enable_fifocache: true
      fifocache:
        max_size_items: 1024
        ttl: 24h
frontend_worker:
  frontend_address: queryFrontend:9095
frontend:
  log_queries_longer_than: 5s
  compress_responses: true
  tail_proxy_url: http://querier:3100
compactor:
  shared_store: filesystem
