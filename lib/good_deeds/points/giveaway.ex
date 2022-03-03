defmodule GoodDeeds.Points.Giveaway do
  import Ecto.Changeset
  alias GoodDeeds.Accounts

  defstruct points: nil, to_email: nil

  @types %{points: :integer, to_email: :string}

  def changeset(giveaway, max_points, exclude_email, params \\ %{}) do
    {giveaway, @types}
    |> cast(params, Map.keys(@types))
    |> validate_required(Map.keys(@types))
    |> validate_number(:points, greater_than_or_equal_to: 1, less_than_or_equal_to: max_points)
    |> validate_format(:to_email, ~r/^[^\s]+@[^\s]+$/,
      message: "must have the @ sign and no spaces"
    )
    |> validate_length(:to_email, max: 160)
    |> validate_exclusion(:to_email, [exclude_email],
      message: "you can't giveaway points to yourself"
    )
    |> validate_change(:to_email, fn :to_email, to_email ->
      cond do
        nil == Accounts.get_user_by_email(to_email) ->
          [to_email: "no user with that email found"]

        true ->
          []
      end
    end)
  end
end
