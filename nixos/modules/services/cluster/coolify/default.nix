{
pkgs,
config,
lib,
...
}:
let
  cfg = config.services.coolify;
  app = cfg.appName;
  domain = cfg.hostname;
  srcDir = "${cfg.package}/share/php/coolify";
  rootDir = "${cfg.dataDir}/srcDir/public";

  phpEnv = pkgs.php.buildEnv {
    extraConfig = ''
      error_reporting = E_ERROR
      error_log = ${cfg.dataDir}/srcDir/storage/logs/php-error.log
      log_errors = On
      log_errors_max_len = 65536
      #ignore_repeated_errors = On
      #ignore_repeated_source = On

      upload_max_filesize = 256M
      post_max_size = 256M
      memory_limit = 512M
    '';
  };
in
  {
  options.services.coolify = {
    enable = lib.mkEnableOption "coolify, a self-hosted SaaS";
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "The hostname as which to register coolify with nginx";
    };
    appName = lib.mkOption {
      type = lib.types.str;
      default = "coolify";
      description = "The app name to use when creating named resources for coolify";
      internal = true;
    };
    package = lib.mkPackageOption pkgs "coolify" { };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/coolify";
      description = "Mutable data dir for coolify";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services."phpfpm-${app}".preStart = let
      mutLinks = [
        "storage"
        "bootstrap/cache"
      ];
      mutSinks = [
        "storage/app/ssh"
        "storage/app/applications"
        "storage/app/databases"
        "storage/app/services"
        "storage/app/backups"
        "storage/app/public"
        "storage/debugbar"
        "storage/logs"
        "storage/framework/cache/data"
        "storage/framework/sessions"
        "storage/framework/testing"
        "storage/framework/views"
        "storage/pail"
        "bootstrap/cache"
      ];
    in ''
      cd ${cfg.dataDir}
      if [[ "$(cat srcVersion)" != "${srcDir}" ]]; then
        rm -rf srcDir
        cp -r "${srcDir}" srcDir
        echo "${srcDir}" >srcVersion
        # TODO migrations
        for f in ${toString mutLinks}; do
          rm -rf srcDir/$f
          ln -s ${cfg.dataDir}/mutDir/$f srcDir/$f
        done
        ln -s ${cfg.dataDir}/.env srcDir/.env
      fi
      for f in ${toString mutSinks}; do
        mkdir -p mutDir/$f
      done
      grep APP_KEY= .env &>/dev/null || echo "APP_KEY=base64:$(${lib.getExe pkgs.openssl} rand -base64 32)" >>.env
      grep APP_ID= .env &>/dev/null || echo "APP_ID=$(${lib.getExe pkgs.openssl} rand -hex 16)" >>.env
      chown -R ${app}:${app} mutDir .env
    '';
    systemd.tmpfiles.settings.coolify = {
      "${cfg.dataDir}".d = { user = app; group = app; mode = "0770"; };
    };

    services.redis.servers.${app} = {
      enable = true;
      port = 0;
      user = app;
      group = app;
      unixSocket = "/run/redis-${app}/redis.sock";
    };

    services.phpfpm.pools.${app} = {
      user = app;
      settings = {
        "listen.owner" = config.services.nginx.user;
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.max_requests" = 500;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 5;
        #"php_admin_value[error_log]" = "stderr";
        #"php_admin_flag[log_errors]" = true;
        "catch_workers_output" = true;
      };
      phpPackage = phpEnv;
      phpEnv = {
        APP_ENV = "local";
        #APP_ID = "";
        APP_NAME = "Coolify";
        #APP_KEY = "";
        APP_URL = "http://coolify";
        #APP_DEBUG = "true";

        DB_CONNECTION = "pgsql";
        DB_USERNAME = app;
        #DB_PASSWORD = "";
        DB_HOST = "/run/postgresql";

        REDIS_HOST = "/run/redis-${app}/redis.sock";
        #REDIS_PASSWORD = "";

        #PUSHER_APP_ID = "";
        #PUSHER_APP_KEY = "";
        #PUSHER_APP_SECRET = "";

        #ROOT_USERNAME = "";
        #ROOT_USER_EMAIL = "";
        #ROOT_USER_PASSWORD = "";
      };
    };
    services.postgresql = {
      enable = true;
      ensureDatabases = [
        app
      ];
      ensureUsers = [
        { name = app; ensureDBOwnership = true; }
      ];
    };
    services.nginx = {
      enable = true;
      virtualHosts.${domain} = {
        root = rootDir;
        extraConfig = ''
          index index.html index.htm index.php;
          charset utf-8;
          client_max_body_size 2048M;
        '';
        locations."/healthcheck" = {
          extraConfig = ''
            access_log off;

            # set max 5 seconds for healthcheck
            fastcgi_read_timeout 5s;

            fastcgi_param  SCRIPT_NAME     /healthcheck;
            fastcgi_param  SCRIPT_FILENAME /healthcheck;
            fastcgi_pass unix:${config.services.phpfpm.pools.${app}.socket};
            include ${pkgs.nginx}/conf/fastcgi_params;
            fastcgi_buffers 8 16k;
            fastcgi_buffer_size 32k;
          '';
        };
        locations."/" = {
          extraConfig = ''
            try_files $uri $uri/ /index.php?$query_string;
          '';
        };
        locations."~ \.php$" = {
          extraConfig = ''
            fastcgi_pass unix:${config.services.phpfpm.pools.${app}.socket};
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include ${pkgs.nginx}/conf/fastcgi_params;
            fastcgi_buffers 16 16k;
            fastcgi_buffer_size 32k;
            fastcgi_read_timeout 99;
          '';
        };
      };
    };
    users.users.${app} = {
      isSystemUser = true;
      home = srcDir;
      group  = app;
    };
    users.groups.${app} = {};
  };
}
