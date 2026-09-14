# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    dwm = prev.dwm.overrideAttrs (oldAttrs: rec {
      patches =
        (oldAttrs.patches or [])
        ++ [
          (prev.fetchpatch {
            url = "https://dwm.suckless.org/patches/systray/dwm-systray-6.7.diff";
            hash = "sha256-XS+D1fg34HzoU2qgS/877WuwM8ydYX4X6SG3Du9G3n4=";
          })
        ];
      configFile = prev.writeText "config.h" (builtins.readFile ../config/dwm/config.h);
      postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
    });
    st = prev.st.overrideAttrs (oldAttrs: rec {
      patches =
        (oldAttrs.patches or [])
        ++ [
          (prev.fetchpatch {
            url = "https://st.suckless.org/patches/clipboard/st-clipboard-0.8.3.diff";
            hash = "sha256-y7N2dem0mGg2wZqtrMYWoAbfgcm/OU6eNXPhZPoYZ88=";
          })
          (prev.fetchpatch {
            url = "https://st.suckless.org/patches/gruber-darker/st-gruber-darker-0.9.2.diff";
            hash = "sha256-sgGboW6l5krwlhhlTDgF/rGxPybD2pE40tleXVSYbTs=";
          })
        ];
      configFile = prev.writeText "config.h" (builtins.readFile ../config/st/config.h);
      postPatch = "${oldAttrs.postPatch}\ncp ${configFile} config.def.h\n";
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
