import Config

config :ms2ex_file,
  mysql_uri: System.get_env("MYSQL_URI") || "mysql://root:password@localhost:3306/maple-data",
  redis_uri: System.get_env("REDIS_URI") || "redis://localhost"
