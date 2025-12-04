{ pkgs, ruby_3_3_6 }:

let
  ruby336 = pkgs.writeShellScriptBin "ruby3.3.6" ''
    export GEM_HOME="$HOME/.gem/ruby/3.3.0"
    export GEM_PATH="$GEM_HOME:${ruby_3_3_6}/lib/ruby/gems/3.3.0"
    export PATH="$GEM_HOME/bin:$PATH"

    exec ${ruby_3_3_6}/bin/ruby "$@"
  '';

  gem336 = pkgs.writeShellScriptBin "gem3.3.6" ''
    export GEM_HOME="$HOME/.gem/ruby/3.3.0"
    export GEM_PATH="$GEM_HOME:${ruby_3_3_6}/lib/ruby/gems/3.3.0"
    export PATH="$GEM_HOME/bin:$PATH"

    exec ${ruby_3_3_6}/bin/gem "$@"
  '';

  bundle336 = pkgs.writeShellScriptBin "bundle3.3.6" ''
    export GEM_HOME="$HOME/.gem/ruby/3.3.0"
    export GEM_PATH="$GEM_HOME:${ruby_3_3_6}/lib/ruby/gems/3.3.0"
    export PATH="$GEM_HOME/bin:$PATH"

    # Make sure pkg-config can see libyaml + libffi (for psych, fiddle, etc.)
    export PKG_CONFIG_PATH=${pkgs.libyaml.dev}/lib/pkgconfig:${pkgs.libffi.dev}/lib/pkgconfig:$PKG_CONFIG_PATH

    exec ${ruby_3_3_6}/bin/bundle "$@"
  '';
in

pkgs.symlinkJoin {
  name = "ruby3.3.6-wrapper";
  paths = [
    ruby336
    gem336
    bundle336
  ];
}
