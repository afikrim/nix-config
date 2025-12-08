# Nix devshell for boon-core Rails application
# Usage: nix develop ~/nix-config#boon-core
# Or add direnv: echo 'use flake ~/nix-config#boon-core' > .envrc

{ pkgs }:

let
  # Build Ruby 3.3.6 from source with YJIT support
  ruby = pkgs.ruby_3_3.override {
    jemallocSupport = true;
  };

  # Node.js 20.x for frontend assets
  nodejs = pkgs.nodejs_20;

in
pkgs.mkShell {
  name = "boon-core-devshell";

  buildInputs = with pkgs; [
    # Ruby and dependencies
    ruby
    bundler
    libyaml
    libffi
    zlib
    openssl

    # Node.js for frontend
    nodejs
    nodePackages.npm

    # PostgreSQL client libraries
    postgresql_16
    libpq

    # Redis/Valkey
    valkey

    # Image processing (for Active Storage)
    imagemagick
    vips
    libheif
    libjpeg
    libpng
    libwebp

    # PDF tools
    wkhtmltopdf
    poppler_utils

    # Browser automation
    chromedriver
    chromium

    # Linting and code generation
    hadolint
    openapi-generator-cli

    # Build essentials
    pkg-config
    gnumake
    gcc
    git
    curl
    jq
    watchman

    # For native gem compilation
    gmp
    readline
    gdbm

    # Mail testing (optional, can also run via docker)
    mailpit
  ];

  shellHook = ''
    # Set environment for macOS fork safety
    export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

    # Ruby/Bundler configuration
    export GEM_HOME="$HOME/.gem/ruby/3.3.0"
    export GEM_PATH="$GEM_HOME:${ruby}/lib/ruby/gems/3.3.0"
    export PATH="$GEM_HOME/bin:$PATH"

    # Ensure bundler uses the correct Ruby
    export BUNDLE_FORCE_RUBY_PLATFORM=1

    # PostgreSQL library paths for pg gem
    export LDFLAGS="-L${pkgs.postgresql_16.lib}/lib -L${pkgs.openssl.out}/lib"
    export CPPFLAGS="-I${pkgs.postgresql_16}/include -I${pkgs.openssl.dev}/include"
    export PKG_CONFIG_PATH="${pkgs.postgresql_16}/lib/pkgconfig:${pkgs.openssl.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"

    # For nokogiri and other native gems
    export NOKOGIRI_USE_SYSTEM_LIBRARIES=1

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
    echo "   PostgreSQL client: $(psql --version)"
    echo ""
    echo "📋 Quick start:"
    echo "   1. Configure Sidekiq: bundle config enterprise.contribsys.com \$SIDEKIQ_ENT_KEY"
    echo "   2. Install dependencies: make install"
    echo "   3. Setup database: make db_setup"
    echo "   4. Start server: make run"
  '';

  # Environment variables
  LANG = "en_US.UTF-8";
  LC_ALL = "en_US.UTF-8";
}
