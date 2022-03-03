defmodule GoodDeedsWeb.PointsControllerTest do
  use GoodDeedsWeb.ConnCase, async: true

  setup :register_and_log_in_user_with_pool

  describe "GET /points" do
    test "render show points page", %{conn: conn} do
      conn = get(conn, Routes.points_path(conn, :show))
      response = html_response(conn, 200)
      assert response =~ "<h4>Your Pool</h4>"
      assert response =~ "<h4>Your Points</h4>"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.points_path(conn, :show))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end

  describe "GET /points/giveaway" do
    test "render giveaway page, user_points pool is more than 0", %{conn: conn} do
      conn = get(conn, Routes.points_path(conn, :giveaway_new))
      response = html_response(conn, 200)
      assert response =~ "<h4 class=\"margin-auto\">Your Pool</h4>"
    end

    test "redirects if user is logged in and user_points pool is 0", %{conn: conn} do
      %{private: %{plug_session: %{"user_token" => user_token}}} = conn

      %{points: points} =
        GoodDeeds.Accounts.get_user_by_session_token(user_token)
        |> GoodDeeds.Repo.preload(:points)

      GoodDeeds.Points.update_user_points(points, %{pool: 0})

      conn = get(conn, Routes.points_path(conn, :giveaway_new))
      assert redirected_to(conn) == Routes.points_path(conn, :show)
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.points_path(conn, :giveaway_new))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end
end
