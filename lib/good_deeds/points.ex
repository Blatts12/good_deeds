defmodule GoodDeeds.Points do
  @moduledoc """
  The Points context.
  """

  import Ecto.Query, warn: false
  alias GoodDeeds.Repo

  alias GoodDeeds.Points.UserPoints
  alias GoodDeeds.Points.GivenPoints

  @doc """
  Returns the list of user_points.

  ## Examples

      iex> list_user_points()
      [%UserPoints{}, ...]

  """
  def list_user_points do
    Repo.all(UserPoints)
  end

  @doc """
  Gets a single user_points.

  Raises `Ecto.NoResultsError` if the User points does not exist.

  ## Examples

      iex> get_user_points!(123)
      %UserPoints{}

      iex> get_user_points!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_points!(id), do: Repo.get!(UserPoints, id)

  @doc """
  Creates a user_points.

  ## Examples

      iex> create_user_points(%{field: value})
      {:ok, %UserPoints{}}

      iex> create_user_points(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_points(attrs \\ %{}) do
    %UserPoints{}
    |> UserPoints.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_points.

  ## Examples

      iex> update_user_points(user_points, %{field: new_value})
      {:ok, %UserPoints{}}

      iex> update_user_points(user_points, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_points(%UserPoints{} = user_points, attrs) do
    user_points
    |> UserPoints.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_points.

  ## Examples

      iex> delete_user_points(user_points)
      {:ok, %UserPoints{}}

      iex> delete_user_points(user_points)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_points(%UserPoints{} = user_points) do
    Repo.delete(user_points)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_points changes.

  ## Examples

      iex> change_user_points(user_points)
      %Ecto.Changeset{data: %UserPoints{}}

  """
  def change_user_points(%UserPoints{} = user_points, attrs \\ %{}) do
    UserPoints.changeset(user_points, attrs)
  end

  @doc """
  Returns the list of given_points.

  ## Examples

      iex> list_given_points()
      [%GivenPoints{}, ...]

  """
  def list_given_points do
    Repo.all(GivenPoints)
  end

  @doc """
  Gets a single given_points.

  Raises `Ecto.NoResultsError` if the Given points does not exist.

  ## Examples

      iex> get_given_points!(123)
      %GivenPoints{}

      iex> get_given_points!(456)
      ** (Ecto.NoResultsError)

  """
  def get_given_points!(id), do: Repo.get!(GivenPoints, id)

  @doc """
  Creates a given_points.

  ## Examples

      iex> create_given_points(%{field: value})
      {:ok, %GivenPoints{}}

      iex> create_given_points(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_given_points(attrs \\ %{}) do
    %GivenPoints{}
    |> GivenPoints.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a given_points.

  ## Examples

      iex> update_given_points(given_points, %{field: new_value})
      {:ok, %GivenPoints{}}

      iex> update_given_points(given_points, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_given_points(%GivenPoints{} = given_points, attrs) do
    given_points
    |> GivenPoints.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a given_points.

  ## Examples

      iex> delete_given_points(given_points)
      {:ok, %UserPoints{}}

      iex> delete_given_points(given_points)
      {:error, %Ecto.Changeset{}}

  """
  def delete_given_points(%GivenPoints{} = given_points) do
    Repo.delete(given_points)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking given_points changes.

  ## Examples

      iex> change_given_points(given_points)
      %Ecto.Changeset{data: %GivenPoints{}}

  """
  def change_given_points(%GivenPoints{} = given_points, attrs \\ %{}) do
    GivenPoints.changeset(given_points, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking giveaway changes.

  ## Examples

      iex> change_given_points(given_points)
      %Ecto.Changeset{data: %{}}

  """
  def change_giveaway(%{} = giveaway, max_points, attrs \\ %{}) do
    GivenPoints.giveaway_changeset(giveaway, max_points, attrs)
  end
end
