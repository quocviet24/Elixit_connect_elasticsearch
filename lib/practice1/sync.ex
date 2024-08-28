defmodule Practice1.Sync do
  alias Practice1.Module.Worker
  alias Practice1.Elasticsearch.Store
  alias Practice1.Elasticsearch.Client
  alias Practice1.Repo
  def sync_postgres_with_elasticsearch() do
    Client.delete_all("workers_index")
    workers = Repo.all(Worker)
    Enum.each(workers, fn worker -> Store.index_worker(worker) end)
  end

  def search_worker_detail(name) do
    query = %{
      "query" => %{
        "match" => %{
          "name" => name
        }
      }
    }
    case Client.search("workers_index", query) do
      {:ok, response} ->
        IO.inspect(response, label: "Elasticsearch Search Response")
        response
      {:error, error} ->
        IO.inspect(error, label: "Elasticsearch Search Error")
        :error
    end
  end

  def search_worker(name) do
    query = %{
      "query" => %{
        "bool" => %{
          "should" => [
            %{
              "match_phrase_prefix" => %{
                "name" => %{
                  "query" => name
                }
              }
            },
            %{
              "fuzzy" => %{
                "name" => %{
                  "value" => name,
                  "fuzziness" => "AUTO"
                }
              }
            },
            %{
              "wildcard" => %{
                "name" => "*#{name}*"
              }
            }
          ]
        }
      }
    }

    case Client.search("workers_index", query) do
      {:ok, %{"hits" => %{"hits" => hits}}} ->
        workers = Enum.map(hits, fn hit -> hit["_source"] end)
        {:ok, workers}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason, label: "Elasticsearch Error")
        {:error, reason}
      _ ->
        {:error, "Unexpected error"}
    end
  end

  def search_worker_id(id) do
    query = %{
      "query" => %{
        "term" => %{
          "_id" => id
        }
      }
    }

    case Client.search("workers_index", query) do
      {:ok, %{"hits" => %{"hits" => [hit | _]}}} ->
        worker = hit["_source"]
        {:ok, worker}

      {:ok, %{"hits" => %{"hits" => []}}} ->
        {:error, "Worker not found"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason, label: "Elasticsearch Error")
        {:error, reason}

      _ ->
        {:error, "Unexpected error"}
    end
  end


  def get_all_worker() do
    # Sử dụng truy vấn match_all để lấy tất cả tài liệu
    query = %{
      "query" => %{
        "match_all" => %{}
      },
      "size" => 1000  # Điều chỉnh số lượng kết quả trả về nếu cần
    }

    case Client.search("workers_index", query) do
      {:ok, %{"hits" => %{"hits" => hits}}} ->
        workers = Enum.map(hits, fn hit ->
          Map.put(hit["_source"], "id", hit["_id"])
        end)
        {:ok, workers}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason, label: "Elasticsearch Error")
        {:error, reason}

      _ ->
        {:error, "Unexpected error"}
    end
  end
end
