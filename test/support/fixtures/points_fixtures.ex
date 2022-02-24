defmodule GoodDeeds.PointsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GoodDeeds.Points` context.
  """

  @doc """
  Generate a user_points.
  """
  def user_points_fixture(attrs \\ %{}) do
    {:ok, user_points} =
      attrs
      |> Enum.into(%{
        points: 42,
        pool: 42
      })
      |> GoodDeeds.Points.create_user_points()

    user_points
  end
end
