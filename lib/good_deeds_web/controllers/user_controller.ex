defmodule GoodDeedsWeb.UserController do
  use GoodDeedsWeb, :controller
  alias GoodDeeds.Repo
  alias GoodDeeds.Accounts.User
  import Ecto.Query

  def index(conn, _params) do
    users =
      Repo.all(
        from u in User,
          join: p in assoc(u, :points),
          preload: [points: p]
      )

    conn
    |> render("index.html", users: users)
  end
end
