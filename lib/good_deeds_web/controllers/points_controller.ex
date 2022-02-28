defmodule GoodDeedsWeb.PointsController do
  use GoodDeedsWeb, :controller
  alias GoodDeeds.Repo
  alias GoodDeeds.Points
  alias GoodDeeds.Accounts
  import Ecto.Changeset

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
        changeset = Points.change_giveaway(%{}, 50)

        render(conn, "giveaway_new.html", points: points, changeset: changeset)
    end
  end

  def giveaway_create(
        %{assigns: %{current_user: from_user}} = conn,
        %{"giveaway" => giveaway}
      ) do
    %{points: points} = from_user |> Repo.preload(:points)
    changeset = Points.change_giveaway(%{}, points.pool, giveaway)

    case apply_action(changeset, :create) do
      {:ok, _giveaway} ->
        case check_user(from_user, giveaway["email"], changeset) do
          %Accounts.User{} = to_user ->
            giveaway_points(from_user, to_user, giveaway["giveaway"])
            redirect(conn, to: Routes.points_path(conn, :show))

          %Ecto.Changeset{} = changeset ->
            changeset = %Ecto.Changeset{changeset | action: :create}

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

  defp check_user(user, email, changeset) do
    case Accounts.get_user_by_email(email) do
      %Accounts.User{} = to_user ->
        cond do
          user.id == to_user.id ->
            add_error(changeset, :email, "You can't giveaway points to yourself")

          true ->
            to_user
        end

      nil ->
        add_error(changeset, :email, "No user with that email found")
    end
  end

  defp giveaway_points(from_user, to_user, points) do
  end
end
