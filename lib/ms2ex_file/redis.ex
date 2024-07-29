defmodule Ms2exFile.Redis do
  @repo :redix

  def flush(),
    do: Redix.command!(@repo, ["flushdb"])

  def count_structs(set) do
    Redix.command!(@repo, ["KEYS", "#{set}:*"]) |> Enum.count()
  end

  def insert_structs(structs, set) do
    pipeline =
      structs
      |> Enum.map(fn {id, struct} ->
        ["SET", "#{set}:#{id}", :erlang.term_to_binary(struct)]
      end)

    Redix.pipeline!(@repo, pipeline)
  end

  def dump() do
    [_cmd, dir] = Redix.command!(@repo, ["config", "get", "dir"])
    Redix.command!(:redix, ["save"])

    dir
  end
end
