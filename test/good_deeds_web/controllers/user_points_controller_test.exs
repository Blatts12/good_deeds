defmodule GoodDeedsWeb.UserPointsControllerTest do
  use GoodDeedsWeb.ConnCase, async: true

  setup :register_and_log_in_user

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

      GoodDeeds.Accounts.get_user_by_session_token(user_token)
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
