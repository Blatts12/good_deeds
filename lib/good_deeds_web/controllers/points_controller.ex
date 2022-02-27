defmodule GoodDeedsWeb.PointsController do
  use GoodDeedsWeb, :controller
  alias GoodDeeds.Repo

  def show(%{assigns: %{current_user: user}} = conn, _params) do
    user_with_points = user |> Repo.preload(points: [:given_points])

    render(conn, "show.html", user_with_points: user_with_points)
  end
end
