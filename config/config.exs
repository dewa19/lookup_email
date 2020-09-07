use Mix.Config

config :logger,
  format: "$message\n",
  level: String.to_atom(System.get_env("LOG_LEVEL") || "debug"),
  handle_otp_reports: true,
  handle_sasl_reports: true
