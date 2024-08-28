defmodule Practice1.Redis do
  @moduledoc """
  Module để kết nối với Redis và cung cấp các hàm truy cập cơ sở dữ liệu Redis.
  """
  def start_link() do
    {:ok, conn} = Redix.start_link(host: "localhost", port: 6379)
    conn
  end

  def set(conn, key, value) do
    Redix.command(conn, ["SETEX", key, "30", value])
  end

  def get(conn, key) do
    Redix.command(conn, ["GET", key])
  end

  def all_key_values(conn) do
    keys = Redix.command!(conn, ["KEYS", "*"])
    values = Redix.command!(conn, ["MGET"] ++ keys)
    Enum.zip(keys, values) |> Enum.into(%{})
  end
end
