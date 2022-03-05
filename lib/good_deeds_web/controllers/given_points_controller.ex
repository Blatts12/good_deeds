defmodule GoodDeedsWeb.GivenPointsController do
  use GoodDeedsWeb, :controller
  alias GoodDeeds.Points

  def index(conn, _params) do
    given_points = Points.list_given_points()

    conn
    |> render("index.html", given_points: given_points)
  end
end
