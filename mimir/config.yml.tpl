activity_tracker:
  filepath: /local/activity.log

blocks_storage:
  backend: s3
  bucket_store:
    max_chunk_pool_bytes: 12884901888 # 12GiB
    sync_dir: "/local/tsdb-sync/"

  s3:
    access_key_id: ${S3_ACCESS_KEY_ID}
    bucket_name: efishery-mimir
    endpoint: s3.ap-southeast-1.amazonaws.com
    # insecure: true
    secret_access_key: ${S3_SECRET_ACCESS_KEY}
    region: ap-southeast-1

  tsdb:
    dir: /local/tsdb

compactor:
  compaction_interval: 30m
  deletion_delay: 2h
  max_closing_blocks_concurrency: 2
  max_opening_blocks_concurrency: 4
  symbols_flushers_concurrency: 4
  data_dir: "/local/"
  sharding_ring:
    wait_stability_min_duration: 1m
    
frontend:
  parallelize_shardable_queries: true
  scheduler_address: mimir-query-scheduler.service.consul:9096

frontend_worker:
  grpc_client_config:
    max_send_msg_size: 419430400 # 400MiB
  scheduler_address: mimir-query-scheduler.service.consul:9096

distributor:
  ring:
    kvstore:
      store: consul
      prefix: mimir-distributed/
      consul:
        host: {{ env "attr.unique.network.ip-address" }}:8500

ingester:
  ring:
    kvstore:
      store: consul
      prefix: mimir-distributed/
      consul:
        host: {{ env "attr.unique.network.ip-address" }}:8500
    final_sleep: 0s
    num_tokens: 512
    tokens_file_path: /local/tokens
    unregister_on_shutdown: false

ingester_client:
  grpc_client_config:
    max_recv_msg_size: 104857600
    max_send_msg_size: 104857600

limits:
  max_query_parallelism: 240
  max_cache_freshness: 10m
  
querier:
  max_concurrent: 16

query_scheduler:
  max_outstanding_requests_per_tenant: 800
  ring:
    kvstore:
      store: consul
      prefix: mimir-distributed/
      consul:
        host: {{ env "attr.unique.network.ip-address" }}:8500

server:
  grpc_server_max_concurrent_streams: 1000
  grpc_server_max_connection_age: 2m
  grpc_server_max_connection_age_grace: 5m
  grpc_server_max_connection_idle: 1m
  http_listen_port: {{ env "NOMAD_PORT_http" }}
  grpc_listen_port: {{ env "NOMAD_PORT_grpc" }}

store_gateway:
  sharding_ring:
    wait_stability_min_duration: 1m
    tokens_file_path: /local/tokens

