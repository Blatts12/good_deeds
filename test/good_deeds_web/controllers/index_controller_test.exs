defmodule GoodDeedsWeb.IndexControllerTest do
  use GoodDeedsWeb.ConnCase, async: true

  describe "GET /" do
    test "renders index page", %{conn: conn} do
      conn = get(conn, Routes.index_path(conn, :index))
      response = html_response(conn, 200)
      assert response =~ "<h1 class=\"text-center margin-auto\">GoodDeeds</h1>"
    end
  end
end
