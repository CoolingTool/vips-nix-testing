{ pkgs ? import <nixpkgs> { }, ... }:

with pkgs;

stdenv.mkDerivation rec {
  pname = "cgif";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "dloebl";
    repo = "cgif";
    rev = "V${version}";
    sha256 = "0mjx27sjx5zfdywx8y3rq6nn1jq9s61rw391r58yamr3dpmqmph9";
  };

  buildInputs = [ glib ];

  nativeBuildInputs = [ meson ninja ];

  outputs = [ "out" ];
}