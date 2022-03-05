defmodule GoodDeedsWeb.GivenPointsController do
  use GoodDeedsWeb, :controller
  alias GoodDeeds.Points.GivenPoints
  alias GoodDeeds.Repo
  import Ecto.Query
  import Ecto.Query.API

  def index(conn, _params) do
    # given_points =
    #   Repo.all(
    #     from given in GivenPoints,
    #       join: user in assoc(given, :user),
    #       join: user_points in assoc(given, :user_points),
    #       join: up_user in assoc(user_points, :user),
    #       preload: [user: user, user_points: {user_points, user: up_user}]
    #   )

    all_given =
      Repo.all(
        from g in GivenPoints,
          group_by: fragment("month"),
          order_by: fragment("month desc"),
          select: {fragment("date_trunc('month', ?) as month", g.inserted_at), count("*")}
      )

    conn
    |> render("index.html", all_given: all_given)
  end
end
