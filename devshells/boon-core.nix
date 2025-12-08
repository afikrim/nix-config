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
    echo "   PostgreSQL client: $(psql --version)"
    echo ""
    echo "⚠️  Note: chromedriver, wkhtmltopdf, mailpit, openapi-generator"
    echo "   are not included. Install via homebrew:"
    echo "   brew install chromedriver wkhtmltopdf mailpit openapi-generator"
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
