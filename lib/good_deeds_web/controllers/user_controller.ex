defmodule GoodDeedsWeb.UserController do
  use GoodDeedsWeb, :controller
  alias GoodDeeds.Accounts

  def index(conn, _params) do
    users = Accounts.list_users()

    conn
    |> render("index.html", users: users)
  end

  def show(conn, %{"id" => user_id}) do
    user = Accounts.get_user!(user_id)

    conn
    |> render("show.html", user: user)
  end
end
