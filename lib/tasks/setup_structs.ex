defmodule Mix.Tasks.Setup.Structs do
  use Mix.Task

  alias Ms2exFile.Structs
  alias Ms2exFile.MySql

  @requirements ["app.start"]
  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:myxql)

    Structs.clean()

    tables = MySql.list_tables()

    tables
    |> Enum.each(fn [table] ->
      fields = MySql.list_columns(table)
      Structs.create(table, fields)
    end)

    IO.puts("Generated #{Enum.count(tables)} structs")
    IO.puts("Setup redis using: mix.setup.redis")
  end
end
