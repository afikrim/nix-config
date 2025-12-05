{ fetchFromGitHub }:
{
  dotbare = fetchFromGitHub {
    owner = "kazhala";
    repo = "dotbare";
    rev = "791d8e08c7b121f7ecb3f2f1a1d763c682048740";
    sha256 = "sha256-/COWQPRKmPpu1XsTpif4uU5ZF+qaQvf1YtVGhAhEKXA=";
  };

  ssh-tunnel = fetchFromGitHub {
    owner = "afikrim";
    repo = "zsh-ssh-tunnel";
    rev = "adb17a37ae56a758761b914dbb148810e38a26b8";
    sha256 = "sha256-A90AmmVo8x3f8Lp8IhHBvQUehY5VDEKbhZ1XeXGhLKE=";
  };

  zsh-autosuggestions = fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-autosuggestions";
    rev = "85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5";
    sha256 = "sha256-KmkXgK1J6iAyb1FtF/gOa0adUnh1pgFsgQOUnNngBaE=";
  };

  zsh-completions = fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-completions";
    rev = "8ddc4416dd4d2804668834bb42067feaddb9bb5a";
    sha256 = "sha256-C8ebCnNPaSPUEDVxIGIWjdOfr/MmxoBwOB/3pNCkzPc=";
  };

  zsh-history-substring-search = fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-history-substring-search";
    rev = "87ce96b1862928d84b1afe7c173316614b30e301";
    sha256 = "sha256-1+w0AeVJtu1EK5iNVwk3loenFuIyVlQmlw8TWliHZGI=";
  };

  zsh-syntax-highlighting = fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-syntax-highlighting";
    rev = "5eb677bb0fa9a3e60f0eff031dc13926e093df92";
    sha256 = "sha256-KRsQEDRsJdF7LGOMTZuqfbW6xdV5S38wlgdcCM98Y/Q=";
  };
}
