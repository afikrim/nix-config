{ pkgs }:

let
  inherit (pkgs) fetchFromGitHub;
in
{
  oh-my-tmux = fetchFromGitHub {
    owner = "gpakosz";
    repo = ".tmux";
    rev = "5b34d9a873b8bfe608004d59b08e81389ce7b6a9";
    hash = "sha256-0suqQJvB7OfUuxw8ruRbBOSjv+hHy2mfwsvJKbg5csQ=";
  };
  tmux-continuum = fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tmux-continuum";
    rev = "0698e8f4b17d6454c71bf5212895ec055c578da0";
    hash = "sha256-W71QyLwC/MXz3bcLR2aJeWcoXFI/A3itjpcWKAdVFJY=";
  };
  tmux-resurrect = fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tmux-resurrect";
    rev = "cff343cf9e81983d3da0c8562b01616f12e8d548";
    hash = "sha256-FcSjYyWjXM1B+WmiK2bqUNJYtH7sJBUsY2IjSur5TjY=";
  };
  tokyo-night-tmux = fetchFromGitHub {
    owner = "janoamaral";
    repo = "tokyo-night-tmux";
    rev = "caf6cbb4c3a32d716dfedc02bc63ec8cf238f632";
    hash = "sha256-TOS9+eOEMInAgosB3D9KhahudW2i1ZEH+IXEc0RCpU0=";
  };
  tpm = fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tpm";
    rev = "99469c4a9b1ccf77fade25842dc7bafbc8ce9946";
    hash = "sha256-hW8mfwB8F9ZkTQ72WQp/1fy8KL1IIYMZBtZYIwZdMQc=";
  };
}
