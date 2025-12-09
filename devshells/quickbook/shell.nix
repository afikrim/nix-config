# Nix devshell for quickbook Rails application (legacy Ruby 2.6.5)
# Usage: nix develop ~/nix-config#quickbook
# Or add direnv: echo 'use flake ~/nix-config#quickbook' > .envrc

{ pkgs }:

let
  # Build Ruby 2.6.5 from source (requires openssl 1.1)
  ruby_2_6_5 = pkgs.callPackage ../../pkgs/ruby_2_6_5.nix {
    openssl = pkgs.openssl_1_1;
  };
  ruby_2_6_5_wrapper = pkgs.callPackage ../../pkgs/ruby_2_6_5_wrapper.nix {
    inherit ruby_2_6_5;
  };
  mysql = pkgs.mysql80;

  rubyGemsPath = "${ruby_2_6_5}/lib/ruby/gems/2.6.0";

  mysqlPort = 3306;
  redisPort = 6379;
  elasticsearchPort = 9200;
in
pkgs.mkShell {
  name = "quickbook-devshell";

  buildInputs = with pkgs; [
    # Ruby 2.6.5
    ruby_2_6_5
    ruby_2_6_5_wrapper

    # Ruby build dependencies
    libyaml
    libffi
    zlib
    openssl_1_1
    libiconv
    pkg-config

    # MySQL 8.0
    mysql

    # Redis
    redis

    # Elasticsearch 7 (legacy)
    elasticsearch

    # Node.js for frontend
    nodejs_14
    yarn

    # Process management
    process-compose

    # Build essentials
    gnumake
    git
    curl
    jq

    # Java for Elasticsearch
    jdk11_headless
  ];

  shellHook = ''
    # Set project root
    if [ -z "''${QUICKBOOK_ROOT:-}" ]; then
      export QUICKBOOK_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    fi

    # Ruby/Bundler configuration
    export GEM_HOME="$QUICKBOOK_ROOT/.nix-gems"
    export GEM_PATH="$GEM_HOME:${rubyGemsPath}"
    export PATH="$GEM_HOME/bin:$PATH"
    export BUNDLE_PATH="$QUICKBOOK_ROOT/vendor/bundle"
    export BUNDLE_BIN="$QUICKBOOK_ROOT/bin"
    export BUNDLE_GEMFILE="$QUICKBOOK_ROOT/Gemfile"

    # C compiler settings for native gem compilation
    export CPATH="${pkgs.libiconv}/include:''${CPATH:-}"
    export LIBRARY_PATH="${pkgs.libiconv}/lib:''${LIBRARY_PATH:-}"
    export CC="${pkgs.stdenv.cc}/bin/clang"
    export CXX="${pkgs.stdenv.cc}/bin/clang++"
    export CXXFLAGS="-std=c++14 ''${CXXFLAGS:-}"
    export CPPFLAGS="-Dregister= ''${CPPFLAGS:-}"

    # PKG_CONFIG_PATH for native gem compilation
    export PKG_CONFIG_PATH="${pkgs.openssl_1_1.dev}/lib/pkgconfig:${mysql}/lib/pkgconfig:$PKG_CONFIG_PATH"

    # Data directories
    export DEV_DATA_DIR="$QUICKBOOK_ROOT/.devdata"
    export DEV_LOG_DIR="$DEV_DATA_DIR/logs"

    # MySQL configuration
    export MYSQL_DATA_DIR="$DEV_DATA_DIR/mysql"
    export MYSQL_LOG_DIR="$DEV_LOG_DIR/mysql"
    export MYSQL_SOCKET="$MYSQL_DATA_DIR/mysql.sock"
    export MYSQL_HOST="127.0.0.1"
    export MYSQL_PORT=${toString mysqlPort}
    export MYSQL_USER="root"
    export MYSQL_PASSWORD=""

    # Redis configuration
    export REDIS_DATA_DIR="$DEV_DATA_DIR/redis"
    export REDIS_HOST="127.0.0.1"
    export REDIS_PORT=${toString redisPort}
    export REDIS_URL="redis://$REDIS_HOST:$REDIS_PORT/0"

    # Elasticsearch 7 configuration
    export ELASTICSEARCH_DATA_DIR="$DEV_DATA_DIR/elasticsearch/data"
    export ELASTICSEARCH_CONFIG_DIR="$DEV_DATA_DIR/elasticsearch/config"
    export ELASTICSEARCH_LOG_DIR="$DEV_LOG_DIR/elasticsearch"
    export ELASTICSEARCH_HOST="127.0.0.1"
    export ELASTICSEARCH_PORT=${toString elasticsearchPort}
    export ELASTICSEARCH_URL="http://$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT"

    # Java for Elasticsearch
    export JAVA_HOME=${pkgs.jdk11_headless}
    export ES_JAVA_HOME=$JAVA_HOME

    # Create directories
    mkdir -p \
      "$GEM_HOME" \
      "$BUNDLE_PATH" \
      "$DEV_DATA_DIR" \
      "$DEV_LOG_DIR" \
      "$MYSQL_DATA_DIR" \
      "$MYSQL_LOG_DIR" \
      "$REDIS_DATA_DIR" \
      "$ELASTICSEARCH_DATA_DIR" \
      "$ELASTICSEARCH_LOG_DIR"

    # Initialize Elasticsearch config
    if [ ! -d "$ELASTICSEARCH_CONFIG_DIR" ]; then
      cp -R ${pkgs.elasticsearch}/config "$ELASTICSEARCH_CONFIG_DIR"
      chmod -R u+rwX "$ELASTICSEARCH_CONFIG_DIR"
    fi

    # Initialize MySQL
    if [ ! -f "$MYSQL_DATA_DIR/.initialized" ]; then
      echo "Initializing MySQL 8.0 data directory in $MYSQL_DATA_DIR"
      mysqld --initialize-insecure --datadir="$MYSQL_DATA_DIR" --basedir=${mysql}
      touch "$MYSQL_DATA_DIR/.initialized"
    fi

    if [ -z "$QUICKBOOK_NIX_SHELL" ]; then
      export QUICKBOOK_NIX_SHELL=1
      echo "Quickbook development environment loaded!"
      echo "   Ruby: $(ruby2.6.5 -v 2>/dev/null || echo 'ruby2.6.5 wrapper')"
      echo "   Node: $(node --version)"
      echo "   MySQL: 8.0"
      echo "   Elasticsearch: 7.x"
      echo ""
      echo "Quick start:"
      echo "   1. Start services: process-compose up"
      echo "   2. Install gems: bundle2.6.5 install"
      echo "   3. Setup database: bundle2.6.5 exec rails db:setup"
      echo "   4. Start Rails: bundle2.6.5 exec rails s"
      echo ""
      echo "Data for stateful services is stored under .devdata/"
    fi
  '';

  LANG = "en_US.UTF-8";
  LC_ALL = "en_US.UTF-8";
}
