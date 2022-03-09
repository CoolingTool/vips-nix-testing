{ pkgs }: let
	luvitPkgs = import ./nix/luvit.nix {};
	cgif = import ./nix/cgif.nix {};
	vipsModifed = pkgs.vips.overrideAttrs (oldAttrs: rec {
		version = "8.12.2";
		src = pkgs.fetchFromGitHub {
			owner = "libvips";
			repo = "libvips";
			rev = "v${version}";
			sha256 = "sha256-ffDJJWe/SzG+lppXEiyfXXL5KLdZgnMjv1SYnuYnh4c=";
			extraPostFetch = ''
			  rm -r $out/test/test-suite/images/
			'';
		};
		buildInputs = oldAttrs.buildInputs ++ [ cgif ];
	});
in {
    deps = [
		luvitPkgs.luvit
		luvitPkgs.lit
		vipsModifed
    ];
	env = { 
		LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
	      vipsModifed
		];
	};
}