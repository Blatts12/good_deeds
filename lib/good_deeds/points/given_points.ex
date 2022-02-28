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

  @doc false
  def giveaway_changeset(giveaway, max_points, attrs) do
    types = %{
      email: :string,
      giveaway: :integer
    }

    {giveaway, types}
    |> cast(attrs, [:giveaway, :email])
    |> validate_required([:giveaway, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> validate_number(:giveaway, greater_than_or_equal_to: 0, less_than_or_equal_to: max_points)
  end
end
