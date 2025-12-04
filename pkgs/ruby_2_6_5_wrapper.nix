{ pkgs, ruby_2_6_5 }:

let
  ruby265 = pkgs.writeShellScriptBin "ruby2.6.5" ''
    export GEM_HOME="$HOME/.gem/ruby/2.6.0"
    export GEM_PATH="$GEM_HOME:${ruby_2_6_5}/lib/ruby/gems/2.6.0"
    export PATH="$GEM_HOME/bin:$PATH"

    exec ${ruby_2_6_5}/bin/ruby "$@"
  '';

  gem265 = pkgs.writeShellScriptBin "gem2.6.5" ''
    export GEM_HOME="$HOME/.gem/ruby/2.6.0"
    export GEM_PATH="$GEM_HOME:${ruby_2_6_5}/lib/ruby/gems/2.6.0"
    export PATH="$GEM_HOME/bin:$PATH"

    exec ${ruby_2_6_5}/bin/gem "$@"
  '';

  bundle265 = pkgs.writeShellScriptBin "bundle2.6.5" ''
    export GEM_HOME="$HOME/.gem/ruby/2.6.0"
    export GEM_PATH="$GEM_HOME:${ruby_2_6_5}/lib/ruby/gems/2.6.0"
    export PATH="$GEM_HOME/bin:$PATH"

    exec ${ruby_2_6_5}/bin/bundle "$@"
  '';
in

pkgs.symlinkJoin {
  name = "ruby2.6.5-wrapper";
  paths = [
    ruby265
    gem265
    bundle265
  ];
}
