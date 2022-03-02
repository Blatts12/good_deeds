defmodule GoodDeedsWeb.PointsController do
  use GoodDeedsWeb, :controller
  alias GoodDeeds.{Repo, Points, Accounts}
  alias GoodDeeds.Points.{GivenPoints, Giveaway}
  import Ecto.Changeset
  import Ecto

  def show(%{assigns: %{current_user: user}} = conn, _params) do
    %{points: points} = user |> Repo.preload(points: [given_points: [:user]])

    render(conn, "show.html", points: points)
  end

  def giveaway_new(%{assigns: %{current_user: user}} = conn, _params) do
    %{points: points} = user |> Repo.preload(:points)

    cond do
      points.pool <= 0 ->
        conn
        |> put_flash(:error, "You don't have enough points in your pool")
        |> redirect(to: Routes.points_path(conn, :show))

      true ->
        changeset = Points.change_giveaway(%Giveaway{}, points.pool, user.email)

        render(conn, "giveaway_new.html", points: points, changeset: changeset)
    end
  end

  def giveaway_create(
        %{assigns: %{current_user: from_user}} = conn,
        %{"giveaway" => giveaway}
      ) do
    %{points: points} = from_user |> Repo.preload(:points)
    changeset = Points.change_giveaway(%Giveaway{}, points.pool, from_user.email, giveaway)

    case apply_action(changeset, :create) do
      {:ok, _giveaway} ->
        to_user = Accounts.get_user_by_email(giveaway["to_email"])

        case giveaway_points(from_user, to_user, giveaway["points"]) do
          {:ok, _result} ->
            redirect(conn, to: Routes.points_path(conn, :show))

          {:error, changeset} ->
            render(conn, "giveaway_new.html",
              points: points,
              changeset: changeset
            )
        end

      {:error, changeset} ->
        render(conn, "giveaway_new.html",
          points: points,
          changeset: changeset
        )
    end
  end

  defp giveaway_points(from_user, to_user, points) do
    points = String.to_integer(points)
    %{points: from_points} = Repo.preload(from_user, :points)
    %{points: to_points} = Repo.preload(to_user, :points)

    Points.update_user_points(from_points, %{pool: from_points.pool - points})
    Points.update_user_points(to_points, %{points: to_points.points + points})

    changeset =
      from_points
      |> build_assoc(:given_points)
      |> change()
      |> put_assoc(:user, to_user)
      |> GivenPoints.changeset(%{given: points})

    Repo.insert(changeset)
  end
end
