defmodule Practice1.Repo do
  use Ecto.Repo,
    otp_app: :practice1,
    adapter: Ecto.Adapters.Postgres
end
