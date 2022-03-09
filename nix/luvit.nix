{ pkgs ? import <nixpkgs> { }, ... }:

with pkgs;

let
  aiverson = {
    name = "Alex Iverson";
    email = "alexjiverson@gmail.com";
  };
  luvi = stdenv.mkDerivation rec {
    name = "luvi-${version}";
    version = "2.13.0";

    src = fetchFromGitHub {
      owner = "luvit";
      repo = "luvi";
      rev = "2be5441f6d85dbb81cb4b37bc67a58a89901e866";
      fetchSubmodules = true;
      sha256 = "0326lxr3z0cl00gpjsnxyvfgwzdaxnbjrx8qm0l70pxxzydxvmc7";
      # release from Oct 20, 2021
    };

    buildInputs = [ cmake openssl ];

    cmakeFlags = [
      "-DWithOpenSSL=ON"
      "-DWithSharedOpenSSL=ON"
      "-DWithPCRE=ON"
      "-DWithLPEG=ON"
      "-DWithSharedPCRE=OFF"
      "-DLUVI_VERSION=${version}"
    ];

    patchPhase = ''
      echo ${version} >> VERSION
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp luvi $out/bin/luvi
    '';

    meta = {
      description = "a lua runtime for applications";
      homepage = "https://github.com/luvit/luvi";

      license = pkgs.lib.licenses.apsl20;
      maintainers = [ aiverson ];
      platforms = pkgs.lib.platforms.linux;
    };
  };

  makeLuviScript = name: source:
    writeBinScript name "${luvi}/bin/luvi ${source} -- $@";
  luviBase = writeScript "luvi" ''
    #!${luvi}/bin/luvi --
  '';

  lit = stdenv.mkDerivation rec {
    name = "lit-${version}";
    version = "3.8.5";

    src = fetchFromGitHub {
      owner = "luvit";
      repo = "lit";
      rev = "84fc5d729f1088b3b93bc9a55d1f7a245bca861d";
      fetchSubmodules = true;
      sha256 = "191fxini7k6a5rvv62aqndpw954a17qii8krc3dqyj6dh26bap7h";
      # release from Jun 25, 2021
    };

    buildInputs = [ luvi strace ];
    buildPhase = ''
      echo database: `pwd`/.litdb.git >> litconfig
      LIT_CONFIG=`pwd`/litconfig luvi . -- make . ./lit ${luviBase} || echo work around bug
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp lit $out/bin/lit
    '';

    meta = {
      description = "packageing tool for luvit";
      homepage = "https://github.com/luvit/lit";

      license = pkgs.lib.licenses.apsl20;
      maintainers = [ aiverson ];
      platforms = pkgs.lib.platforms.linux;
    };
  };

  makeLitPackage = { buildInputs ? [ ], ... }@args:
    stdenv.mkDerivation ({
      buildPhase = ''
        echo database: `pwd`/.litdb.git >> litconfig
        export LIT_CONFIG=`pwd`/litconfig
        lit install || echo work around bug
        lit make . ./$pname ${luviBase} || echo work around bug
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp ./$pname $out/bin/$pname
      '';
    } // args // {
      buildInputs = [ lit ] ++ buildInputs;
    });

  luvit = makeLitPackage rec {
    name = "luvit-${version}";
    pname = "luvit";
    version = "2.18.1";

    src = fetchFromGitHub {
      owner = "luvit";
      repo = "luvit";
      rev = "b7d27154429471da42c83a6be355572cfa319772";
      sha256 = "06yp31igdxmnfga9gn7z0n5sdbr5p69vd8saj16b6ifl45zg66wz";
      # release from Nov 18, 2021
    };

    meta = {
      description = "a lua runtime for application";
      homepage = "https://github.com/luvit/luvi";

      license = pkgs.lib.licenses.apsl20;
      maintainers = [ aiverson ];
      platforms = pkgs.lib.platforms.linux;
    };
  };

  lua = lua52Packages.lua.withPackages (p: with p; [ lpeg ]);

in { inherit luvit luvi lit makeLitPackage; }
