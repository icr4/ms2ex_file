defmodule Mix.Tasks.File.Setup do
  use Mix.Task

  alias Ms2exFile.MySql
  alias Ms2exFile.Redis
  alias Ms2exFile.Parser

  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    Application.ensure_all_started(:myxql)
    tables = get_arg(args, :t)

    tables =
      if length(tables) > 0 do
        tables
      else
        Redis.flush()
        MySql.list_tables()
      end

    IO.puts("Processing #{inspect(tables)}")

    tables
    |> Enum.map(fn [table] ->
      count = MySql.count(table)

      IO.puts("[#{table}] Reading #{count} records from MySQL...")

      primaries = MySql.get_primaries_keys(table)

      data = MySql.paginate(table, primaries, 0)
      {table, data}
    end)
    |> Map.new()
    |> Parser.process()
    |> Enum.each(fn {table, data} ->
      IO.inspect("[#{table}] Caching data into redis")
      store_values(table, data)
    end)
  end

  defp store_values(table, data) do
    set = Macro.underscore(table)
    Redis.insert_sets(set, data)
  end

  defp get_arg(args, :t) do
    (args -- ["-t"]) |> Enum.map(fn t -> [t] end)
  end
end
