defmodule GoodDeedsWeb.UserRegistrationController do
  use GoodDeedsWeb, :controller
  import Ecto

  alias GoodDeeds.Accounts
  alias GoodDeeds.Points
  alias GoodDeeds.Repo
  alias GoodDeeds.Accounts.User
  alias GoodDeeds.Points.UserPoints
  alias GoodDeedsWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        user
        |> build_assoc(:points, user_id: user.id)
        |> Repo.insert()

        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
