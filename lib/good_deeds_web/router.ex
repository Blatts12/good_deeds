defmodule GoodDeedsWeb.Router do
  use GoodDeedsWeb, :router

  import GoodDeedsWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GoodDeedsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GoodDeedsWeb do
    pipe_through :browser

    get "/", IndexController, :index
  end

  scope "/points", GoodDeedsWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", UserPointsController, :show
    get "/giveaway", GiveawayController, :new
    post "/giveaway", GiveawayController, :create
  end

  scope "/given_points", GoodDeedsWeb do
    pipe_through [:browser, :require_authenticated_user]

    delete "/:id/cancel", GivenPointsController, :cancel
  end

  scope "/admin", GoodDeedsWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin_user]

    get "/", IndexController, :admin
    get "/users", UserController, :index
    get "/user_points/:id", UserPointsController, :edit
    put "/user_points/:id", UserPointsController, :update
    get "/given_points", GivenPointsController, :index
    get "/given_points/list/:year/:month", GivenPointsController, :list
    get "/given_points/summary/:year/:month", GivenPointsController, :summary
    post "/pool_reset", UserPointsController, :trigger_pool_reset
  end

  # Other scopes may use custom stacks.
  # scope "/api", GoodDeedsWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GoodDeedsWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  # if Mix.env() == :dev do
  #   scope "/dev" do
  #     pipe_through :browser

  #     forward "/mailbox", Plug.Swoosh.MailboxPreview
  #   end
  # end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  ## Authentication routes

  scope "/", GoodDeedsWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", GoodDeedsWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", GoodDeedsWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end
