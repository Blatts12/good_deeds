defmodule GoodDeedsWeb.UserPointsControllerTest do
  use GoodDeedsWeb.ConnCase, async: true

  setup :register_and_log_in_user_with_pool

  describe "GET /points" do
    test "render show points page", %{conn: conn} do
      conn = get(conn, Routes.user_points_path(conn, :show))
      response = html_response(conn, 200)
      assert response =~ "<h4>Your Pool</h4>"
      assert response =~ "<h4>Your Points</h4>"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.user_points_path(conn, :show))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end

  describe "GET /admin/user_points/:id" do
    test "redirect if user is not admin", %{conn: conn} do
      conn = get(conn, Routes.user_points_path(conn, :edit, 1))
      assert redirected_to(conn) == Routes.index_path(conn, :index)
    end

    test "redirect if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.user_points_path(conn, :edit, 1))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end

    test "renders edit page", %{conn: conn} do
      %{private: %{plug_session: %{"user_token" => user_token}}} = conn
      user = GoodDeeds.Accounts.get_user_by_session_token(user_token)
      %{points: user_points} = user |> GoodDeeds.Repo.preload(:points)

      user
      |> GoodDeeds.Accounts.User.role_changeset(%{role: "admin"})
      |> GoodDeeds.Repo.update()

      conn = get(conn, Routes.user_points_path(conn, :edit, user_points.id))
      response = html_response(conn, 200)

      assert response =~ "<h1 class=\"header text-center margin-auto\">Update points</h1>"

      assert response =~
               "<input id=\"user_points_pool\" min=\"0\" name=\"user_points[pool]\" required type=\"number\""
    end
  end

  describe "POST /admin/user_points/:id" do
    test "updates user_points", %{conn: conn} do
      %{private: %{plug_session: %{"user_token" => user_token}}} = conn
      user = GoodDeeds.Accounts.get_user_by_session_token(user_token)
      %{points: user_points} = user |> GoodDeeds.Repo.preload(:points)

      user
      |> GoodDeeds.Accounts.User.role_changeset(%{role: "admin"})
      |> GoodDeeds.Repo.update()

      conn =
        put(conn, Routes.user_points_path(conn, :update, user_points.id), %{
          "user_points" => %{"pool" => "100", "points" => "100"}
        })

      assert redirected_to(conn) == Routes.user_path(conn, :index)

      conn = get(conn, Routes.user_points_path(conn, :edit, user_points.id))
      response = html_response(conn, 200)

      assert response =~
               "<input id=\"user_points_pool\" min=\"0\" name=\"user_points[pool]\" required type=\"number\" value=\"100\">"

      assert response =~
               "<input id=\"user_points_points\" min=\"0\" name=\"user_points[points]\" required type=\"number\" value=\"100\">"
    end

    test "renders errors for invalid data", %{conn: conn} do
      %{private: %{plug_session: %{"user_token" => user_token}}} = conn
      user = GoodDeeds.Accounts.get_user_by_session_token(user_token)
      %{points: user_points} = user |> GoodDeeds.Repo.preload(:points)

      user
      |> GoodDeeds.Accounts.User.role_changeset(%{role: "admin"})
      |> GoodDeeds.Repo.update()

      conn =
        put(conn, Routes.user_points_path(conn, :update, user_points.id), %{
          "user_points" => %{"pool" => "-20", "points" => "-20"}
        })

      response = html_response(conn, 200)

      assert response =~ "\"user_points[pool]\">must be greater than or equal to 0"
      assert response =~ "\"user_points[points]\">must be greater than or equal to 0"
    end
  end

  describe "POST /admin/pool_reset" do
    test "redirect if user is not admin", %{conn: conn} do
      conn = post(conn, Routes.user_points_path(conn, :trigger_pool_reset))
      assert redirected_to(conn) == Routes.index_path(conn, :index)
    end

    test "redirect if user is not logged in" do
      conn = build_conn()
      conn = post(conn, Routes.user_points_path(conn, :trigger_pool_reset))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end

    test "reset pool points", %{conn: conn} do
      %{private: %{plug_session: %{"user_token" => user_token}}} = conn
      user = GoodDeeds.Accounts.get_user_by_session_token(user_token)
      %{points: user_points} = user |> GoodDeeds.Repo.preload(:points)
      GoodDeeds.Points.update_user_points(user_points, %{pool: 0})

      user
      |> GoodDeeds.Accounts.User.role_changeset(%{role: "admin"})
      |> GoodDeeds.Repo.update()

      %{assigns: %{points: points}} = get(conn, Routes.user_points_path(conn, :show))
      assert points.pool == 0

      conn = post(conn, Routes.user_points_path(conn, :trigger_pool_reset))
      %{assigns: %{points: points}} = get(conn, Routes.user_points_path(conn, :show))
      assert points.pool == 50
    end
  end
end
