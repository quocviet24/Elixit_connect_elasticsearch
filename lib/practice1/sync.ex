defmodule Practice1.Sync do
  alias Practice1.Module.Worker
  alias Practice1.Elasticsearch.Store
  alias Practice1.Elasticsearch.Client
  alias Practice1.Repo
  def sync_postgres_with_elasticsearch() do
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
        "match" => %{
          "name" => name
        }
      }
    }

    case Client.search("workers_index", query) do
      {:ok, %{"hits" => %{"hits" => hits}}} ->
        IO.puts("Found documents:")
        Enum.each(hits, fn hit ->
          IO.inspect(hit["_source"], label: "Document")
        end)
        :ok

      {:error, reason} ->
        IO.inspect(reason, label: "Elasticsearch Search Error")
    end
  end
end
