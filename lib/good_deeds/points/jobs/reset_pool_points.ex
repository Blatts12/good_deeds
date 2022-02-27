defmodule GoodDeeds.Points.Jobs.ResetPoolPoints do
  alias GoodDeeds.Repo
  alias GoodDeeds.Points.UserPoints

  def reset_pool_points do
    Repo.update_all(UserPoints, set: [pool: 50])
  end
end
