let
	luvitPkgs = import (fetchTarball "https://github.com/CoolingTool/luvit-nix/archive/fork.tar.gz") {};
in { pkgs }: {
    deps = [
		luvitPkgs.luvit
		luvitPkgs.lit
		pkgs.vips
    ];
	env = {
		LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
	      pkgs.vips
	    ];
	};
}