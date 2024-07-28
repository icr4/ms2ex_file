defmodule Mix.Tasks.Setup.Structs do
  use Mix.Task

  alias Ms2exFile.Structs

  @repo :myxql
  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:myxql)

    Structs.clean()

    {:ok, %MyXQL.Result{rows: tables}} = MyXQL.query(@repo, "SHOW TABLES")

    tables
    |> Enum.each(fn [t] ->
      {:ok, %MyXQL.Result{rows: fields}} = MyXQL.query(@repo, "SHOW COLUMNS FROM `#{t}`")

      Structs.create(t, fields)
    end)

    IO.inspect("Generated #{Enum.count(tables)} structs")
    IO.inspect("Setup redis using:")
    IO.inspect("mix setup.redis")
  end
end
