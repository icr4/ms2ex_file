import Config

config :ms2ex_file,
  mysql_uri: "mysql://root:password@localhost:3306/maple_data",
  redis_uri: "redis://localhost"

# hostname: System.get_env("DB_HOST") || "admin.taakagency.it",
# username: System.get_env("DB_USER") || "root",
# password: System.get_env("DB_PASS") || "password",
# database: System.get_env("DB_NAME") || "maple_data",
# port: System.get_env("DB_PORT") || 3308

# config :ms2ex_file, :redix, host: System.get_env("RD_HOST") || "localhost"
