defmodule GoodDeeds.Repo.Migrations.CreateUserPoints do
  use Ecto.Migration

  def change do
    create table(:user_points) do
      add :points, :integer
      add :pool, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:user_points, [:user_id])
  end
end
