defmodule GoodDeeds.Repo do
  use Ecto.Repo,
    otp_app: :good_deeds,
    adapter: Ecto.Adapters.Postgres
end
