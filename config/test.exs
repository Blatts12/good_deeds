import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :pbkdf2_elixir, :rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :good_deeds, GoodDeeds.Repo,
  username: "dev",
  password: "zaq1@WSX",
  hostname: "localhost",
  database: "good_deeds_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# Bamboo configuration
config :good_deeds, GoodDeeds.Mailer, adapter: Bamboo.TestAdapter

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :good_deeds, GoodDeedsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "YVtOYKFOoi1uPY8rhX6Ngfu131kiX53Q0SvhNTrXvMo2LLJ0ONRISYi4UDb2TV1n",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
