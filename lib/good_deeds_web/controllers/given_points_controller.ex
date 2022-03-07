defmodule GoodDeedsWeb.GivenPointsController do
  use GoodDeedsWeb, :controller
  alias GoodDeeds.Points.GivenPoints
  alias GoodDeeds.Points
  alias GoodDeeds.Accounts
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

  def cancel(conn, %{"id" => given_id}) do
    %{assigns: %{current_user: user}} = conn

    case Repo.get(GivenPoints, given_id) do
      %GivenPoints{} = given_points ->
        given_points = Repo.preload(given_points, :user_points)

        cond do
          given_points.user_points.user_id == user.id || user.role == "admin" ->
            today = Date.utc_today()

            cond do
              !given_points.canceled ->
                cond do
                  today.month == given_points.inserted_at.month &&
                      today.year == given_points.inserted_at.year ->
                    to_user = Accounts.get_user!(given_points.user_id)
                    ungiveaway_points(user, to_user, given_points.given)
                    Points.update_given_points(given_points, %{canceled: true})

                    conn
                    |> put_flash(:info, "Reward has been cancelled")
                    |> redirect(to: Routes.index_path(conn, :index))

                  true ->
                    conn
                    |> put_flash(:error, "Reward is too old to be cancelled")
                    |> redirect(to: Routes.index_path(conn, :index))
                end

              true ->
                conn
                |> put_flash(:error, "Reward already cancelled")
                |> redirect(to: Routes.index_path(conn, :index))
            end

          true ->
            conn
            |> put_flash(:error, "You can't do that")
            |> redirect(to: Routes.index_path(conn, :index))
        end

      nil ->
        conn
        |> put_flash(:error, "Resource don't exists")
        |> redirect(to: Routes.index_path(conn, :index))
    end
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
            today = Date.utc_today()
            cancellable = today.year == start_date.year && today.month == start_date.month

            conn
            |> render("list.html", given_points: given_points, cancellable: cancellable)
        end
    end
  end

  def summary(conn, %{"year" => year, "month" => month}) do
    start_date = get_start_of_month(year, month)
    end_date = get_end_of_month(year, month)

    cond do
      start_date == nil || end_date == nil ->
        conn
        |> put_flash(:error, "Wrong date")
        |> redirect(to: Routes.given_points_path(conn, :index))

      true ->
        received_query =
          from given in GivenPoints,
            where: fragment("? between ? and ?", given.inserted_at, ^start_date, ^end_date),
            join: user in assoc(given, :user),
            group_by: [user.id, given.user_id],
            select: %{
              user_id: given.user_id,
              email: user.email,
              received: sum(given.given),
              gifted: 0
            }

        gifted_query =
          from given in GivenPoints,
            where: fragment("? between ? and ?", given.inserted_at, ^start_date, ^end_date),
            join: user_points in assoc(given, :user_points),
            join: up_user in assoc(user_points, :user),
            group_by: [user_points.user_id, up_user.email],
            select: %{
              user_id: user_points.user_id,
              email: up_user.email,
              received: 0,
              gifted: sum(given.given)
            }

        given_summary =
          Repo.all(
            from s in subquery(union(received_query, ^gifted_query)),
              select: %{
                user_id: s.user_id,
                email: s.email,
                received: sum(s.received),
                gifted: sum(s.gifted)
              },
              group_by: [s.user_id, s.email]
          )

        conn
        |> render("summary.html", summary: given_summary)
    end
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

  defp ungiveaway_points(from_user, to_user, points) do
    %{points: from_points} = Repo.preload(from_user, :points)
    %{points: to_points} = Repo.preload(to_user, :points)

    Points.update_user_points(from_points, %{pool: from_points.pool + points})
    Points.update_user_points(to_points, %{points: to_points.points - points})
  end
end
