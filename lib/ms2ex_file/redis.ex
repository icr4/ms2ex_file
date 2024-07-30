defmodule Ms2exFile.Redis do
  @repo :redix

  def flush(),
    do: Redix.command!(@repo, ["flushdb"])

  def insert_sets(set, data) do
    pipeline =
      data
      |> Enum.map(fn map ->
        ["SET", "#{set}:#{map.redis_id}", :erlang.term_to_binary(map)]
      end)

    Redix.pipeline!(@repo, pipeline)
  end
end
