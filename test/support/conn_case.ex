defmodule GoodDeedsWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use GoodDeedsWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import GoodDeedsWeb.ConnCase

      alias GoodDeedsWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint GoodDeedsWeb.Endpoint
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(GoodDeeds.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = GoodDeeds.AccountsFixtures.user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Setup helper that registers with pool 50 and logs in users.

      setup :register_and_log_in_user_with_pool

  It stores an updated connection and a registered user with pool 50 in the
  test context.
  """
  def register_and_log_in_user_with_pool(%{conn: conn}) do
    user = GoodDeeds.AccountsFixtures.user_fixture()

    user
    |> Ecto.build_assoc(:points, user_id: user.id)
    |> GoodDeeds.Points.UserPoints.changeset(%{points: 50, pool: 50})
    |> GoodDeeds.Repo.insert()

    user = GoodDeeds.Repo.preload(user, :points)

    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Setup helper that registers with pool 0 and logs in users.

      setup :register_and_log_in_user_with_no_pool

  It stores an updated connection and a registered user with pool 0 in the
  test context.
  """
  def register_and_log_in_user_with_no_pool(%{conn: conn}) do
    user = GoodDeeds.AccountsFixtures.user_fixture()

    user
    |> Ecto.build_assoc(:points, user_id: user.id)
    |> GoodDeeds.Points.UserPoints.changeset(%{points: 50, pool: 0})
    |> GoodDeeds.Repo.insert()

    user = GoodDeeds.Repo.preload(user, :points)

    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = GoodDeeds.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end
end
