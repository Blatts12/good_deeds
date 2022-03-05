defmodule GoodDeedsWeb.GivenPointsController do
  use GoodDeedsWeb, :controller
  alias GoodDeeds.Points.GivenPoints
  alias GoodDeeds.Repo
  import Ecto.Query

  def index(conn, _params) do
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

  def list(conn, %{"year" => year, "month" => month}) do
    {:ok, start_date} = get_start_of_month(year, month)
    {:ok, end_date} = get_end_of_month(year, month)

    given_points =
      Repo.all(
        from given in GivenPoints,
          where: fragment("? between ? and ?", given.inserted_at, ^start_date, ^end_date),
          join: user in assoc(given, :user),
          join: user_points in assoc(given, :user_points),
          join: up_user in assoc(user_points, :user),
          preload: [user: user, user_points: {user_points, user: up_user}]
      )

    conn
    |> render("list.html", given_points: given_points)
  end

  defp get_start_of_month(year, month) do
    time = ~T[00:00:00.000]

    case Date.new(String.to_integer(year), String.to_integer(month), 1) do
      {:ok, date} ->
        date
        |> DateTime.new(time)

      {:error, _why} ->
        nil
    end
  end

  defp get_end_of_month(year, month) do
    time = ~T[00:00:00.000]

    case Date.new(String.to_integer(year), String.to_integer(month), 1) do
      {:ok, date} ->
        date
        |> Date.end_of_month()
        |> DateTime.new(time)

      {:error, _why} ->
        nil
    end
  end
end
