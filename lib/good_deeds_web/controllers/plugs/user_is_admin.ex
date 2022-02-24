defmodule GoodDeeds.Plugs.UserIsAdmin do
  import Plug.Conn
  import Phoenix.Controller

  alias GoodDeedsWeb.Router.Helpers, as: Routes

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns.user[:role] == "admin" do
      conn
    else
      conn
      |> put_flash(:error, "You don't have permissions to do that.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
