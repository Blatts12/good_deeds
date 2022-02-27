defmodule GoodDeeds.Repo.Migrations.CreateGivenPoints do
  use Ecto.Migration

  def change do
    create table(:given_points) do
      add :given, :integer
      add :canceled, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :user_points_id, references(:user_points, on_delete: :nothing)

      timestamps()
    end

    create index(:given_points, [:user_id])
    create index(:given_points, [:user_points_id])
  end
end
