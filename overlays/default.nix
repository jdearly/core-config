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
            url = "https://dwm.suckless.org/patches/status2d/dwm-status2d-systray-6.4.diff";
            hash = "sha256-SfKtvPQ4N8DvmL2a9hj/Cr1cRGDVHj6RllnjBVZfBm8=";
          })
        ];
      # configFile = prev.writeText "config.h" (builtins.readFile ../config/dwm/config.h);
      # postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
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
    # specifically using unstable temporarily, with 26.06 the surf-2.1 package is broken
    surf = (import inputs.nixpkgs-unstable {
         inherit (prev) system;
         config = prev.config; 
    }).surf;
    # Figure this out.. 
    # surf = prev.surf.overrideAttrs (oldAttrs: rec {
    #   patches =
    #     (oldAttrs.patches or [])
    #     ++ [
    #       (prev.fetchpatch {
    #         url = "https://surf.suckless.org/patches/homepage/surf-2.0-homepage.diff";
    #         hash = "";
    #       })
    #     ];
    # });
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
