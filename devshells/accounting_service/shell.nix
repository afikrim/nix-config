# Nix devshell for accounting_service Go application
# Usage: nix develop ~/nix-config#accounting_service
# Or add direnv: echo 'use flake ~/nix-config#accounting_service' > .envrc

{ pkgs }:

let
  swag = pkgs.buildGoModule {
    pname = "swag";
    version = "1.16.4";
    src = pkgs.fetchFromGitHub {
      owner = "swaggo";
      repo = "swag";
      rev = "v1.16.4";
      hash = "sha256-wqBT7uan5XL51HHDGINRH9NTb1tybF44d/rWRxl6Lak=";
    };
    vendorHash = "sha256-6L5LzXtYjrA/YKmNEC/9dyiHpY/8gkH/CvW0JTo+Bwc=";
    subPackages = [ "cmd/swag" ];
    doCheck = false;
  };

  mysqlPort = 3306;
  redisPort = 6379;
  elasticsearchHttpPort = 9200;
  elasticsearchTransportPort = 9300;
  kafkaPort = 9092;
  zookeeperPort = 2181;
in
pkgs.mkShell {
  name = "accounting-service-devshell";

  buildInputs = with pkgs; [
    # Go and build tools
    go_1_24
    gnumake
    git
    pkg-config
    curl

    # Go tooling
    sqlc
    mockgen
    golangci-lint
    swag

    # Services
    mysql80
    redis
    elasticsearch
    apacheKafka
    zookeeper

    # Process management
    process-compose
    kcat

    # Java for Kafka/ES
    jdk17_headless
  ];

  shellHook = ''
    export DEVENV_ROOT="$PWD"
    export GOBIN="$DEVENV_ROOT/.bin"
    mkdir -p "$GOBIN"
    export PATH="$GOBIN:$PATH"

    # Data directories
    export DEV_DATA_DIR="$DEVENV_ROOT/.devdata"
    export DEV_LOG_DIR="$DEV_DATA_DIR/logs"

    # MySQL configuration
    export MYSQL_DATA_DIR="$DEV_DATA_DIR/mysql"
    export MYSQL_LOG_DIR="$DEV_LOG_DIR/mysql"
    export MYSQL_SOCKET="$MYSQL_DATA_DIR/mysql.sock"
    export MYSQL_PID_FILE="$MYSQL_DATA_DIR/mysql.pid"
    export MYSQL_HOST="127.0.0.1"
    export MYSQL_PORT=${toString mysqlPort}
    export MYSQL_USER="root"
    export MYSQL_PASSWORD=""
    export MYSQL_DB="jurnal_dev"
    export MYSQL_HOST_TEST="$MYSQL_HOST"
    export MYSQL_PORT_TEST="$MYSQL_PORT"
    export MYSQL_USER_TEST="$MYSQL_USER"
    export MYSQL_PASSWORD_TEST="$MYSQL_PASSWORD"
    export MYSQL_DB_TEST="accounting_test"

    # Redis configuration
    export REDIS_DATA_DIR="$DEV_DATA_DIR/redis"
    export REDIS_HOST="127.0.0.1"
    export REDIS_PORT=${toString redisPort}
    export REDIS_ADDR="$REDIS_HOST:$REDIS_PORT"
    export REDIS_HOST_TEST="$REDIS_HOST"
    export REDIS_PORT_TEST="$REDIS_PORT"
    export ASYNCQ_REDIS_ADDR="$REDIS_ADDR"

    # Elasticsearch configuration
    export ELASTICSEARCH_DATA_DIR="$DEV_DATA_DIR/elasticsearch/data"
    export ELASTICSEARCH_CONFIG_DIR="$DEV_DATA_DIR/elasticsearch/config"
    export ELASTICSEARCH_LOG_DIR="$DEV_LOG_DIR/elasticsearch"
    export ELASTICSEARCH_HOST="127.0.0.1"
    export ELASTICSEARCH_HTTP_PORT=${toString elasticsearchHttpPort}
    export ELASTICSEARCH_TRANSPORT_PORT=${toString elasticsearchTransportPort}
    export ELASTICSEARCH_URL="http://$ELASTICSEARCH_HOST:$ELASTICSEARCH_HTTP_PORT"

    # Zookeeper configuration
    export ZOOKEEPER_DATA_DIR="$DEV_DATA_DIR/zookeeper/data"
    export ZOOKEEPER_LOG_DIR="$DEV_LOG_DIR/zookeeper"
    export ZOOKEEPER_HOST="127.0.0.1"
    export ZOOKEEPER_PORT=${toString zookeeperPort}
    export ZOO_LOG_DIR="$ZOOKEEPER_LOG_DIR"

    # Kafka configuration
    export KAFKA_LOG_DIR="$DEV_DATA_DIR/kafka/logs"
    export KAFKA_HOST="127.0.0.1"
    export KAFKA_PORT=${toString kafkaPort}
    export KAFKA_BROKER_1="$KAFKA_HOST:$KAFKA_PORT"
    export KAFKA_BROKER_2="$KAFKA_HOST:$KAFKA_PORT"
    export KAFKA_BROKER_3="$KAFKA_HOST:$KAFKA_PORT"

    # Create data directories
    mkdir -p \
      "$DEV_DATA_DIR" \
      "$DEV_LOG_DIR" \
      "$MYSQL_DATA_DIR" \
      "$MYSQL_LOG_DIR" \
      "$REDIS_DATA_DIR" \
      "$ELASTICSEARCH_DATA_DIR" \
      "$ELASTICSEARCH_LOG_DIR" \
      "$ZOOKEEPER_DATA_DIR" \
      "$ZOOKEEPER_LOG_DIR" \
      "$KAFKA_LOG_DIR"

    ln -snf "$ELASTICSEARCH_LOG_DIR" "$DEVENV_ROOT/logs"

    # Initialize Elasticsearch config
    if [ ! -d "$ELASTICSEARCH_CONFIG_DIR" ]; then
      cp -R ${pkgs.elasticsearch}/config "$ELASTICSEARCH_CONFIG_DIR"
      chmod -R u+rwX "$ELASTICSEARCH_CONFIG_DIR"
    fi

    if [ -f "$ELASTICSEARCH_CONFIG_DIR/jvm.options" ]; then
      perl -0pi -e 's#logs/gc.log#'"$ELASTICSEARCH_LOG_DIR"'/gc.log#g' "$ELASTICSEARCH_CONFIG_DIR/jvm.options"
    fi

    # Initialize Kafka storage
    if [ ! -f "$KAFKA_LOG_DIR/meta.properties" ]; then
      echo "Initializing Kafka storage in $KAFKA_LOG_DIR"
      CLUSTER_ID=$(kafka-storage.sh random-uuid)
      kafka-storage.sh format --ignore-formatted --cluster-id "$CLUSTER_ID" --config dev/services/kafka/server.properties >/dev/null 2>&1 || true
    fi

    # Initialize MySQL
    if [ ! -f "$MYSQL_DATA_DIR/.initialized" ]; then
      echo "Initializing MySQL data directory in $MYSQL_DATA_DIR"
      mysqld --initialize-insecure --datadir="$MYSQL_DATA_DIR" --basedir=${pkgs.mysql80}
      touch "$MYSQL_DATA_DIR/.initialized"
    fi

    # Java configuration for Kafka/ES
    export JAVA_HOME=${pkgs.jdk17_headless}
    export ES_JAVA_HOME=$JAVA_HOME
    export ES_HOME=${pkgs.elasticsearch}
    export ES_LOG_DIR="$ELASTICSEARCH_LOG_DIR"
    export ES_PATH_CONF="$ELASTICSEARCH_CONFIG_DIR"

    if [ -z "$ACCOUNTING_SERVICE_NIX_SHELL" ]; then
      export ACCOUNTING_SERVICE_NIX_SHELL=1
      echo "Accounting Service development environment loaded!"
      echo "   Go: $(go version | cut -d' ' -f3)"
      echo ""
      echo "Quick start:"
      echo "   1. Start services: process-compose up"
      echo "   2. Run tests: go test ./..."
      echo "   3. Run linter: make lint"
      echo ""
      echo "Data for stateful services is stored under .devdata/"
    fi
  '';

  LANG = "en_US.UTF-8";
  LC_ALL = "en_US.UTF-8";
}
