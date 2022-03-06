defmodule GoodDeedsWeb.GivenPointsControllerTest do
  use GoodDeedsWeb.ConnCase, async: true

  setup :register_and_log_in_user_with_pool

  describe "GET /admin/given_points" do
    test "redirect if user is not admin", %{conn: conn} do
      conn = get(conn, Routes.given_points_path(conn, :index))
      assert redirected_to(conn) == Routes.index_path(conn, :index)
    end

    test "redirect if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.given_points_path(conn, :index))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end

  describe "GET /admin/list/:year/:month" do
    test "redirect if user is not admin", %{conn: conn} do
      conn = get(conn, Routes.given_points_path(conn, :list, "2022", "4"))
      assert redirected_to(conn) == Routes.index_path(conn, :index)
    end

    test "redirect if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.given_points_path(conn, :list, "2022", "4"))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end

  describe "GET /admin/summary/:year/:month" do
    test "redirect if user is not admin", %{conn: conn} do
      conn = get(conn, Routes.given_points_path(conn, :summary, "2022", "4"))
      assert redirected_to(conn) == Routes.index_path(conn, :index)
    end

    test "redirect if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.given_points_path(conn, :summary, "2022", "4"))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end
end
