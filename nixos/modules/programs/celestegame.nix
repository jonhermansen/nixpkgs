{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.celestegame;
  nullableEverest = if cfg.withEverest then cfg.everestPackage else null;
  finalPackage = cfg.package.override {
    inherit (cfg) writableDir;
    overrideSrc = cfg.source;
    everest = nullableEverest;
  };
  finalOlympusPackage = cfg.olympusPackage.override {
    celesteWrapper = if cfg.useSteam then pkgs.steam-run else null;
    installHints = lib.optional (!cfg.useSteam) "${cfg.gameDir}";
  };
in
  {
  options.programs.celestegame = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to configure Celeste (2018), a 2D platformer about climbing a mountain.";
      relatedPackages = [ "celestegame" ];
    };

    package = lib.mkPackageOption pkgs "celestegame" { };

    useSteam = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Set to true to not manage the Celeste/Everest install and instead assume it will be installed by Steam.
      '';
    };

    source = lib.mkOption {
      type = lib.types.nullOr lib.types.pathInStore;
      default = null;
      description = "Path of celeste-linux.zip if it is not manually added to the store";
    };

    withEverest = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to install Everest, the Celeste modloader";
    };

    useEverestBinaryDistribution = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to use the everest binary distribution instead of a nix-based build.
        Useful for precisely reporting bugs to upstream.
      '';
    };

    everestPackage = lib.mkPackageOption pkgs [ "celestegame" "everest" ] { };

    withOlympus = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to install Olympus, the modded Celeste launcher and installation manager.
      '';
    };

    olympusPackage = lib.mkPackageOption pkgs "olympus" { };

    writableDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        A directory to store mutable state related to a modded Celeste install, notably mod files.
        Without this option, Everest will not be able to install mods since it is installed in the nix store.
      '';
    };

    gameDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "/etc/celestegame";
      description = ''
        A directory to symlink to the global Celeste installation.
        Without this option, Olympus will think each rebuild of the celestegame derivation is a new installation of Celeste.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.celestegame.everestPackage = lib.mkIf cfg.useEverestBinaryDistribution pkgs.celestegame.everest-bin;
    environment.systemPackages = lib.optionals (!cfg.useSteam) [
      finalPackage
    ] ++ lib.optionals cfg.withOlympus [
      finalOlympusPackage
    ];
    environment.etc.celestegame.source = "${finalPackage}/lib/Celeste";
  };
}
