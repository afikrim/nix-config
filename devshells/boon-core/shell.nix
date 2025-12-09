# Nix devshell for boon-core Rails application
# Usage: nix develop ~/nix-config#boon-core
# Or add direnv: echo 'use flake ~/nix-config#boon-core' > .envrc

{ pkgs }:

let
  # Build Ruby 3.3.6 from source to match Gemfile requirement
  ruby = pkgs.callPackage ../pkgs/ruby_3_3_6.nix { };
in
pkgs.mkShell {
  name = "boon-core-devshell";

  buildInputs = with pkgs; [
    # Ruby and dependencies
    ruby
    libyaml
    libffi
    zlib
    openssl

    # For nokogiri
    libxml2
    libxslt

    # Node.js 22 for frontend
    nodejs_22

    # Python 3.11 for libv8-node build
    python311

    # PostgreSQL client libraries
    postgresql_16

    # Redis/Valkey
    valkey

    # Image processing (for Active Storage)
    imagemagick
    vips
    libpng
    libwebp

    # Linting
    hadolint

    # Process management
    process-compose

    # Mail testing
    mailpit

    # Build essentials
    pkg-config
    gnumake
    git
    curl
    jq

    # For native gem compilation
    gmp
    readline
    gdbm
  ];

  shellHook = ''
    # Set environment for macOS fork safety
    export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

    # Ruby/Bundler configuration
    export GEM_HOME="$HOME/.gem/ruby/3.3.6"
    export GEM_PATH="$GEM_HOME:${ruby}/lib/ruby/gems/3.3.0"
    export PATH="$GEM_HOME/bin:$PATH"

    # PKG_CONFIG_PATH for native gem compilation (pg, nokogiri, etc.)
    export PKG_CONFIG_PATH="${pkgs.postgresql_16}/lib/pkgconfig:${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.libxml2.dev}/lib/pkgconfig:${pkgs.libxslt.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"

    # PostgreSQL data directory
    export PGDATA="$HOME/.local/share/boon-postgres"
    export PGHOST="localhost"
    export PGUSER="postgres"
    export PGPASSWORD="password"
    export PGDATABASE="boon_development"

    # Initialize PostgreSQL if needed
    if [ ! -d "$PGDATA" ]; then
      echo "📦 Initializing PostgreSQL database..."
      initdb -D "$PGDATA" --no-locale --encoding=UTF8 --username=postgres --auth=md5 --pwfile=<(echo "password")
      echo "unix_socket_directories = '$PGDATA'" >> "$PGDATA/postgresql.conf"
      echo "listen_addresses = 'localhost'" >> "$PGDATA/postgresql.conf"
      echo "port = 5432" >> "$PGDATA/postgresql.conf"
      # Allow password auth from localhost
      echo "host all all 127.0.0.1/32 md5" >> "$PGDATA/pg_hba.conf"
      echo "host all all ::1/128 md5" >> "$PGDATA/pg_hba.conf"
    fi

    # Create database after postgres starts (run once)
    _create_boon_db() {
      if pg_isready -h localhost -p 5432 -U postgres >/dev/null 2>&1; then
        if ! psql -h localhost -U postgres -lqt | cut -d \| -f 1 | grep -qw boon_development; then
          echo "📦 Creating boon_development database..."
          createdb -h localhost -U postgres boon_development
        fi
      fi
    }
    export -f _create_boon_db

    # For libvips (image processing)
    export VIPS_WARNING=0

    # For imagemagick
    export MAGICK_HOME="${pkgs.imagemagick}"

    # Disable Spring in dev for stability
    export DISABLE_SPRING=0

    # Node.js memory settings
    export NODE_OPTIONS="--max-old-space-size=4096"

    echo "🚀 Boon Core development environment loaded!"
    echo "   Ruby: $(ruby --version)"
    echo "   Node: $(node --version)"
    echo "   Python: $(python3 --version)"
    echo "   PostgreSQL: $(postgres --version)"
    echo ""
    echo "📋 Quick start:"
    echo "   1. Start services: process-compose up"
    echo "   2. Configure Sidekiq: bundle config enterprise.contribsys.com \$SIDEKIQ_ENT_KEY"
    echo "   3. Install dependencies: make install"
    echo "   4. Setup database: make db_setup"
    echo "   5. Start Rails: make run"
    echo ""
    echo "⚠️  Optional (via homebrew): chromedriver, wkhtmltopdf, openapi-generator"
  '';

  # Environment variables
  LANG = "en_US.UTF-8";
  LC_ALL = "en_US.UTF-8";
}
