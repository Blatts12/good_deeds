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

    test "renders list of rewards per month", %{conn: conn} do
      %{private: %{plug_session: %{"user_token" => user_token}}} = conn

      GoodDeeds.Accounts.get_user_by_session_token(user_token)
      |> GoodDeeds.Accounts.User.role_changeset(%{role: "admin"})
      |> GoodDeeds.Repo.update()

      conn =
        post(conn, Routes.giveaway_path(conn, :create), %{
          "giveaway" => %{"points" => "25", "to_email" => "test_case@example.com"}
        })

      # date_today = Date.utc_today()

      conn = get(conn, Routes.given_points_path(conn, :index))
      response = html_response(conn, 200)

      assert response =~ "<h2 class=\"text-center margin-auto\">Given Points</h2>"
      assert response =~ "01T00:00:00.000000</span> -\n1\n        rewards"
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

    test "renders list of rewards for month", %{conn: conn} do
      %{private: %{plug_session: %{"user_token" => user_token}}} = conn

      GoodDeeds.Accounts.get_user_by_session_token(user_token)
      |> GoodDeeds.Accounts.User.role_changeset(%{role: "admin"})
      |> GoodDeeds.Repo.update()

      conn =
        post(conn, Routes.giveaway_path(conn, :create), %{
          "giveaway" => %{"points" => "25", "to_email" => "test_case@example.com"}
        })

      today = Date.utc_today()

      conn = get(conn, Routes.given_points_path(conn, :list, today.year, today.month))
      response = html_response(conn, 200)

      assert response =~ "<h2 class=\"text-center margin-auto\">List of rewards</h2>"
      assert response =~ "<li>\ntest_case@example.com\n      received\n25\n      points from"
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

    test "renders summary of rewards for month", %{conn: conn} do
      %{private: %{plug_session: %{"user_token" => user_token}}} = conn

      GoodDeeds.Accounts.get_user_by_session_token(user_token)
      |> GoodDeeds.Accounts.User.role_changeset(%{role: "admin"})
      |> GoodDeeds.Repo.update()

      conn =
        post(conn, Routes.giveaway_path(conn, :create), %{
          "giveaway" => %{"points" => "25", "to_email" => "test_case@example.com"}
        })

      today = Date.utc_today()

      conn = get(conn, Routes.given_points_path(conn, :summary, today.year, today.month))
      response = html_response(conn, 200)

      assert response =~ "<h2 class=\"text-center margin-auto\">Summary</h2>"
      assert response =~ "<td>test_case@example.com</td>\r\n      <td>25</td>\r\n      <td>0</td>"
    end
  end
end
