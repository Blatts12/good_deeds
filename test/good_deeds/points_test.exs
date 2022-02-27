defmodule GoodDeeds.PointsTest do
  use GoodDeeds.DataCase

  alias GoodDeeds.Points

  describe "user_points" do
    alias GoodDeeds.Points.UserPoints

    import GoodDeeds.PointsFixtures

    @invalid_attrs %{points: nil, pool: nil}
    @invalid_attrs_under_limit %{points: -10, pool: -10}
    @invalid_attrs_over_limit %{points: 10, pool: 60}

    test "list_user_points/0 returns all user_points" do
      user_points = user_points_fixture()
      assert Points.list_user_points() == [user_points]
    end

    test "get_user_points!/1 returns the user_points with given id" do
      user_points = user_points_fixture()
      assert Points.get_user_points!(user_points.id) == user_points
    end

    test "create_user_points/1 with valid data creates a user_points" do
      valid_attrs = %{points: 42, pool: 42}

      assert {:ok, %UserPoints{} = user_points} = Points.create_user_points(valid_attrs)
      assert user_points.points == 42
      assert user_points.pool == 42
    end

    test "create_user_points/1 with invalid data, pool and points under limit, returns error changeset" do
      {:error, changeset} = Points.create_user_points(@invalid_attrs_under_limit)

      assert %{
               points: ["must be greater than or equal to 0"],
               pool: ["must be greater than or equal to 0"]
             } = errors_on(changeset)
    end

    test "create_user_points/1 with invalid data, pool over limit, returns error changeset" do
      {:error, changeset} = Points.create_user_points(@invalid_attrs_over_limit)

      assert %{pool: ["must be less than or equal to 50"]} = errors_on(changeset)
    end

    test "update_user_points/2 with valid data updates the user_points" do
      user_points = user_points_fixture()
      update_attrs = %{points: 43, pool: 43}

      assert {:ok, %UserPoints{} = user_points} =
               Points.update_user_points(user_points, update_attrs)

      assert user_points.points == 43
      assert user_points.pool == 43
    end

    test "update_user_points/2 with invalid data returns error changeset" do
      user_points = user_points_fixture()
      assert {:error, %Ecto.Changeset{}} = Points.update_user_points(user_points, @invalid_attrs)
      assert user_points == Points.get_user_points!(user_points.id)
    end

    test "delete_user_points/1 deletes the user_points" do
      user_points = user_points_fixture()
      assert {:ok, %UserPoints{}} = Points.delete_user_points(user_points)
      assert_raise Ecto.NoResultsError, fn -> Points.get_user_points!(user_points.id) end
    end

    test "change_user_points/1 returns a user_points changeset" do
      user_points = user_points_fixture()
      assert %Ecto.Changeset{} = Points.change_user_points(user_points)
    end
  end

  describe "given_points" do
    alias GoodDeeds.Points.GivenPoints

    import GoodDeeds.PointsFixtures

    @invalid_attrs %{canceled: nil, given: nil}
    @invalid_attrs_under_limit %{canceled: false, given: -10}
    @invalid_attrs_over_limit %{canceled: false, given: 60}

    test "list_given_points/0 return all given_points" do
      given_points = given_points_fixture()
      assert Points.list_given_points() == [given_points]
    end

    test "get_given_points!/1 returns the given_points with given id" do
      given_points = given_points_fixture()
      assert Points.get_given_points!(given_points.id) == given_points
    end

    test "create_given_points/1 with valid data creates a given_points" do
      valid_attrs = %{canceled: false, given: 20}

      assert {:ok, %GivenPoints{} = given_points} = Points.create_given_points(valid_attrs)
      assert given_points.given == 20
      assert given_points.canceled == false
    end

    test "create_given_points/1 with invalid data, given over limit, returns error changeset" do
      {:error, changeset} = Points.create_given_points(@invalid_attrs_over_limit)

      assert %{given: ["must be less than or equal to 50"]} = errors_on(changeset)
    end

    test "create_given_points/1 with invalid data, given under limit, returns error changeset" do
      {:error, changeset} = Points.create_given_points(@invalid_attrs_under_limit)

      assert %{given: ["must be greater than or equal to 0"]} = errors_on(changeset)
    end

    test "update_given_points/2 with valid data updates the given_points" do
      given_points = given_points_fixture()
      update_attrs = %{canceled: true, given: 45}

      assert {:ok, %GivenPoints{} = given_points} =
               Points.update_given_points(given_points, update_attrs)

      assert given_points.given == 45
      assert given_points.canceled == true
    end

    test "update_given_points/2 with invalid data returns error changeset" do
      given_points = given_points_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Points.update_given_points(given_points, @invalid_attrs)

      assert given_points == Points.get_given_points!(given_points.id)
    end

    test "delete_given_points/1 deletes the given_points" do
      given_points = given_points_fixture()
      assert {:ok, %GivenPoints{}} = Points.delete_given_points(given_points)
      assert_raise Ecto.NoResultsError, fn -> Points.get_given_points!(given_points.id) end
    end

    test "change_given_points/1 returns a given_points changeset" do
      given_points = given_points_fixture()
      assert %Ecto.Changeset{} = Points.change_given_points(given_points)
    end
  end
end
