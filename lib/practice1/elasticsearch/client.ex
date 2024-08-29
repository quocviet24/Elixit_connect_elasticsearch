defmodule Practice1.Elasticsearch.Client do
  @url "http://localhost:9200"
  @username "elastic"
  @password "Z2RZk5a5LjvWfzTr*P6O"

  def index(index, id, body) do
    url = "#{@url}/#{index}/_doc/#{id}"
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Basic #{Base.encode64("#{@username}:#{@password}")}"}
    ]
    case HTTPoison.put(url, Jason.encode!(body), headers) do
      {:ok, response} ->
        IO.inspect(response.body, label: "Elasticsearch Response Body")
        :ok
      {:error, reason} ->
        IO.inspect(reason, label: "Elasticsearch Error")
        :error
    end
  end

  def search(index, query) do
    url = "#{@url}/#{index}/_search"
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Basic " <> Base.encode64("#{@username}:#{@password}")}
    ]
    body = Jason.encode!(query)
    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        {:ok, Jason.decode!(response_body)}
      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
        {:error, %{status: status_code, body: Jason.decode!(response_body)}}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def delete_all(index_name) do
    url = "#{@url}/#{index_name}/_delete_by_query"
    body = %{
      "query" => %{
        "match_all" => %{}
      }
    }
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Basic " <> Base.encode64("#{@username}:#{@password}")}
    ]

    case HTTPoison.post(url, Jason.encode!(body), headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok, "Deleted all documents in #{index_name}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason, label: "Elasticsearch Error")
        {:error, reason}
    end
  end

end
