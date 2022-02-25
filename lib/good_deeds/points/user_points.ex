defmodule GoodDeeds.Points.UserPoints do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_points" do
    field :points, :integer, default: 0
    field :pool, :integer, default: 0
    belongs_to :user, GoodDeeds.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(user_points, attrs \\ %{}) do
    user_points
    |> cast(attrs, [:points, :pool])
    |> validate_required([:points, :pool])
    |> validate_number(:points, greater_than_or_equal_to: 0)
    |> validate_number(:pool, greater_than_or_equal_to: 0, less_than_or_equal_to: 50)
  end
end
