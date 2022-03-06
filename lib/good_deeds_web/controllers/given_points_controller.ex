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
    start_date = get_start_of_month(year, month)
    end_date = get_end_of_month(year, month)

    cond do
      start_date == nil || end_date == nil ->
        conn
        |> put_flash(:error, "Wrong date")
        |> redirect(to: Routes.given_points_path(conn, :index))

      true ->
        given_points =
          Repo.all(
            from given in GivenPoints,
              where: fragment("? between ? and ?", given.inserted_at, ^start_date, ^end_date),
              join: user in assoc(given, :user),
              join: user_points in assoc(given, :user_points),
              join: up_user in assoc(user_points, :user),
              preload: [user: user, user_points: {user_points, user: up_user}]
          )

        case given_points do
          [] ->
            conn
            |> put_flash(:error, "No rewards for provided date found")
            |> redirect(to: Routes.given_points_path(conn, :index))

          [%GivenPoints{} | _] ->
            conn
            |> render("list.html", given_points: given_points)
        end
    end
  end

  def summary(conn, %{"year" => year, "month" => month}) do
    conn
    |> render("summary.html")
  end

  defp get_start_of_month(year, month) do
    time = ~T[00:00:00.000]

    year = Integer.parse(year)
    month = Integer.parse(month)

    cond do
      year == :error || month == :error ->
        nil

      true ->
        case Date.new(elem(year, 0), elem(month, 0), 1) do
          {:ok, date} ->
            {:ok, date_time} =
              date
              |> DateTime.new(time)

            date_time

          {:error, _why} ->
            nil
        end
    end
  end

  defp get_end_of_month(year, month) do
    time = ~T[00:00:00.000]

    year = Integer.parse(year)
    month = Integer.parse(month)

    cond do
      year == :error || month == :error ->
        nil

      true ->
        case Date.new(elem(year, 0), elem(month, 0), 1) do
          {:ok, date} ->
            {:ok, date_time} =
              date
              |> Date.end_of_month()
              |> DateTime.new(time)

            date_time

          {:error, _why} ->
            nil
        end
    end
  end
end
