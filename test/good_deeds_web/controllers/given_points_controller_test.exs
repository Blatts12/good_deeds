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

  describe "DELETE /given_points/:id/cancel" do
    test "redirect if user is not logged in" do
      conn = build_conn()
      conn = delete(conn, Routes.given_points_path(conn, :cancel, "1"))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end

    test "redirect and info flash if given_points has been cancelled, user is owner", %{
      conn: conn
    } do
      %{private: %{plug_session: %{"user_token" => user_token}}} = conn
      user = GoodDeeds.Accounts.get_user_by_session_token(user_token)
      %{points: user_points} = user |> GoodDeeds.Repo.preload(:points)

      conn =
        post(conn, Routes.giveaway_path(conn, :create), %{
          "giveaway" => %{"points" => "25", "to_email" => "test_case@example.com"}
        })

      given_points =
        GoodDeeds.Repo.get_by(GoodDeeds.Points.GivenPoints,
          given: 25,
          user_points_id: user_points.id
        )

      conn = delete(conn, Routes.given_points_path(conn, :cancel, given_points.id))

      assert redirected_to(conn, 302) == Routes.index_path(conn, :index)
      assert get_flash(conn) == %{"info" => "Reward has been cancelled"}
    end

    test "redirect and info flash if given_points has been cancelled, user is admin", %{
      conn: admin_conn
    } do
      %{private: %{plug_session: %{"user_token" => admin_token}}} = admin_conn

      GoodDeeds.Accounts.get_user_by_session_token(admin_token)
      |> GoodDeeds.Accounts.User.role_changeset(%{role: "admin"})
      |> GoodDeeds.Repo.update()

      admin_user = GoodDeeds.Accounts.get_user_by_session_token(admin_token)

      user = GoodDeeds.Accounts.get_user_by_email("test_case@example.com")
      %{points: user_points} = user |> GoodDeeds.Repo.preload(:points)
      user_token = GoodDeeds.Accounts.generate_user_session_token(user)

      user_conn =
        build_conn()
        |> Phoenix.ConnTest.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, user_token)

      post(user_conn, Routes.giveaway_path(user_conn, :create), %{
        "giveaway" => %{"points" => "25", "to_email" => admin_user.email}
      })

      given_points =
        GoodDeeds.Repo.get_by(GoodDeeds.Points.GivenPoints,
          given: 25,
          user_points_id: user_points.id
        )

      admin_conn =
        delete(admin_conn, Routes.given_points_path(admin_conn, :cancel, given_points.id))

      assert redirected_to(admin_conn, 302) == Routes.index_path(admin_conn, :index)
      assert get_flash(admin_conn) == %{"info" => "Reward has been cancelled"}
    end

    test "redirect and error flash if given_points doesn't exists", %{conn: conn} do
      conn = delete(conn, Routes.given_points_path(conn, :cancel, 1))

      assert redirected_to(conn, 302) == Routes.index_path(conn, :index)
      assert get_flash(conn) == %{"error" => "Resource don't exists"}
    end

    test "redirect and error flash if given_points has been already cancelled", %{conn: conn} do
      %{private: %{plug_session: %{"user_token" => user_token}}} = conn
      user = GoodDeeds.Accounts.get_user_by_session_token(user_token)
      %{points: user_points} = user |> GoodDeeds.Repo.preload(:points)

      conn =
        post(conn, Routes.giveaway_path(conn, :create), %{
          "giveaway" => %{"points" => "25", "to_email" => "test_case@example.com"}
        })

      given_points =
        GoodDeeds.Repo.get_by(GoodDeeds.Points.GivenPoints,
          given: 25,
          user_points_id: user_points.id
        )

      conn = delete(conn, Routes.given_points_path(conn, :cancel, given_points.id))
      conn = delete(conn, Routes.given_points_path(conn, :cancel, given_points.id))

      assert redirected_to(conn, 302) == Routes.index_path(conn, :index)

      assert get_flash(conn) == %{
               "error" => "Reward already cancelled",
               "info" => "Reward has been cancelled"
             }
    end

    test "redirect and error flash if given_points is too old to be cancelled", %{conn: conn} do
      %{private: %{plug_session: %{"user_token" => user_token}}} = conn
      user = GoodDeeds.Accounts.get_user_by_session_token(user_token)
      %{points: user_points} = user |> GoodDeeds.Repo.preload(:points)

      conn =
        post(conn, Routes.giveaway_path(conn, :create), %{
          "giveaway" => %{"points" => "25", "to_email" => "test_case@example.com"}
        })

      given_points =
        GoodDeeds.Repo.get_by(GoodDeeds.Points.GivenPoints,
          given: 25,
          user_points_id: user_points.id
        )

      {:ok, old_datetime} =
        Date.add(given_points.inserted_at, -33)
        |> DateTime.new(~T[13:26:08.003])

      GoodDeeds.Repo.query("UPDATE given_points SET inserted_at = $1 WHERE id = $2", [
        old_datetime,
        given_points.id
      ])

      conn = delete(conn, Routes.given_points_path(conn, :cancel, given_points.id))

      assert redirected_to(conn, 302) == Routes.index_path(conn, :index)
      assert get_flash(conn) == %{"error" => "Reward is too old to be cancelled"}
    end

    test "redirect and error flash if user isn't given_points owner", %{conn: user_conn} do
      %{private: %{plug_session: %{"user_token" => user_token}}} = user_conn

      user = GoodDeeds.Accounts.get_user_by_session_token(user_token)

      other_user = GoodDeeds.Accounts.get_user_by_email("test_case@example.com")
      %{points: other_user_points} = other_user |> GoodDeeds.Repo.preload(:points)
      other_user_token = GoodDeeds.Accounts.generate_user_session_token(other_user)

      other_user_conn =
        build_conn()
        |> Phoenix.ConnTest.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, other_user_token)

      post(other_user_conn, Routes.giveaway_path(other_user_conn, :create), %{
        "giveaway" => %{"points" => "25", "to_email" => user.email}
      })

      given_points =
        GoodDeeds.Repo.get_by(GoodDeeds.Points.GivenPoints,
          given: 25,
          user_points_id: other_user_points.id
        )

      user_conn = delete(user_conn, Routes.given_points_path(user_conn, :cancel, given_points.id))

      assert redirected_to(user_conn, 302) == Routes.index_path(user_conn, :index)
      assert get_flash(user_conn) == %{"error" => "You can't do that"}
    end
  end
end
