defmodule GoodDeedsWeb.UserController do
  use GoodDeedsWeb, :controller
  alias GoodDeeds.Accounts

  def index(conn, _params) do
    users = Accounts.list_users()

    conn
    |> render("index.html", users: users)
  end
end
