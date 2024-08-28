defmodule Practice1.Redis do
  @moduledoc """
  Module để kết nối với Redis và cung cấp các hàm truy cập cơ sở dữ liệu Redis.
  """
  @redis_opts [host: "localhost", port: 6379]
  @redis_conn_name :redis_connection

  # Khởi tạo kết nối Redis và lưu vào môi trường ứng dụng
  def start_link do
    {:ok, conn} = Redix.start_link(@redis_opts)
    Application.put_env(:practice1, @redis_conn_name, conn)
    {:ok, conn}
  end

  defp get_conn do
    Application.get_env(:practice1, @redis_conn_name)
  end

  def set(key, value) do
    conn = get_conn()
    case Redix.command(conn, ["SETEX", key, "200", value]) do
      {:ok, "OK"} -> :ok
      {:ok, other} -> {:error, "Unexpected response: #{other}"}
      {:error, reason} -> {:error, reason}
    end
  end

  def get(key) do
    conn = get_conn()
    case conn do
      nil -> {:error, "Redis connection not found"}
      _ -> Redix.command(conn, ["GET", key])
    end
  end

  def all_key_values() do
    conn = get_conn()
    case Redix.command(conn, ["KEYS", "*"]) do
      {:ok, keys} ->
        if length(keys) > 0 do
          case Redix.command(conn, ["MGET"] ++ keys) do
            {:ok, values} ->
              key_value_map = Enum.zip(keys, values) |> Enum.into(%{})
              {:ok, key_value_map}
            {:error, reason} -> {:error, reason}
          end
        else
          {:ok, %{}}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  def flush_all do
    conn = get_conn()

    case Redix.command(conn, ["FLUSHALL"]) do
      {:ok, "OK"} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def flush_db do
    conn = get_conn()

    case Redix.command(conn, ["FLUSHDB"]) do
      {:ok, "OK"} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
