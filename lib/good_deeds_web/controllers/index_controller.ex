defmodule GoodDeedsWeb.IndexController do
  use GoodDeedsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def admin(conn, _params) do
    render(conn, "admin.html")
  end
end
