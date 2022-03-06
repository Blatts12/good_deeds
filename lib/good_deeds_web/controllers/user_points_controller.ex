defmodule GoodDeedsWeb.UserPointsController do
  use GoodDeedsWeb, :controller
  alias GoodDeeds.Repo
  alias GoodDeeds.Points

  def show(%{assigns: %{current_user: user}} = conn, _params) do
    %{points: points} = user |> Repo.preload(points: [given_points: [:user]])

    render(conn, "show.html", points: points, today: Date.utc_today())
  end

  def trigger_pool_reset(conn, _params) do
    Points.Jobs.ResetPoolPoints.reset_pool_points()

    conn
    |> put_flash(:info, "Pools has been resetted")
    |> redirect(to: Routes.index_path(conn, :admin))
  end
end
