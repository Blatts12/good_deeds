defmodule GoodDeeds.Points.GivenPoints do
  use Ecto.Schema
  import Ecto.Changeset

  schema "given_points" do
    field :canceled, :boolean, default: false
    field :given, :integer
    belongs_to :user, GoodDeeds.Accounts.User
    belongs_to :user_points, GoodDeeds.Points.UserPoints

    timestamps()
  end

  @doc false
  def changeset(given_points, attrs) do
    given_points
    |> cast(attrs, [:given, :canceled])
    |> validate_required([:given, :canceled])
    |> validate_number(:given, greater_than_or_equal_to: 0, less_than_or_equal_to: 50)
  end
end
