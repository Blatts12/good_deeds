defmodule GoodDeedsWeb.UserPointsController do
  use GoodDeedsWeb, :controller
  alias GoodDeeds.Repo
  alias GoodDeeds.Points
  alias GoodDeeds.Points.UserPoints

  def show(%{assigns: %{current_user: user}} = conn, _params) do
    %{points: points} = user |> Repo.preload(points: [given_points: [:user]])

    render(conn, "show.html", points: points, today: Date.utc_today())
  end

  def edit(conn, %{"id" => user_points_id}) do
    case Repo.get(UserPoints, user_points_id) do
      %UserPoints{} = user_points ->
        %{user: user} = user_points |> Repo.preload(:user)
        changeset = Points.change_user_points(user_points)

        conn
        |> render("edit.html", changeset: changeset, user: user, user_points: user_points)

      nil ->
        conn
        |> put_flash(:error, "Resource don't exists")
        |> redirect(to: Routes.index_path(conn, :index))
    end
  end

  def update(conn, %{"user_points" => user_points, "id" => user_points_id}) do
    old_user_points = Repo.get(UserPoints, user_points_id)
    changeset = Points.change_user_points(old_user_points, user_points)

    case Repo.update(changeset) do
      {:ok, _user_points} ->
        conn
        |> put_flash(:info, "User Points Updated")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, changeset} ->
        %{user: user} = old_user_points |> Repo.preload(:user)

        conn
        |> render("edit.html", changeset: changeset, user: user, user_points: old_user_points)
    end
  end

  def trigger_pool_reset(conn, _params) do
    Points.Jobs.ResetPoolPoints.reset_pool_points()

    conn
    |> put_flash(:info, "Pools has been resetted")
    |> redirect(to: Routes.index_path(conn, :admin))
  end
end
