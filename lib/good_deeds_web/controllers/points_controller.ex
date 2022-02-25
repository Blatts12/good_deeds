defmodule GoodDeedsWeb.PointsController do
  use GoodDeedsWeb, :controller
  import Ecto

  def show(%{assigns: %{current_user: user}} = conn, _params) do
    points = user |> build_assoc(:points)

    render(conn, "show.html", points: points)
  end
end
