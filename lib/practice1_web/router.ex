defmodule Practice1Web.Router do
  use Practice1Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Practice1Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Practice1Web do
    pipe_through :browser

    get "/", WorkerController, :list_worker
    get "/create", WorkerController, :page_create
    get "/worker/:id" , WorkerController, :show_detail
    get "/:id/edit", WorkerController, :edit
    delete "/:id", WorkerController, :delete
    post "/create", WorkerController, :create_worker
    post "/search", WorkerController, :search
    get "/redis", WorkerController, :all_redis
    get "/postgres_all", WorkerController, :index
  end


  # Other scopes may use custom stacks.
  # scope "/api", Practice1Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:practice1, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Practice1Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
