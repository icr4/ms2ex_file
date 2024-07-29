defmodule Ms2exFile.MySql do
  @repo :myxql
  @page_size 500

  def list_tables() do
    {:ok, %MyXQL.Result{rows: tables}} = MyXQL.query(@repo, "SHOW TABLES")

    tables
  end

  def list_columns(table) do
    {:ok, %MyXQL.Result{rows: fields}} = MyXQL.query(@repo, "SHOW COLUMNS FROM `#{table}`")

    fields
  end

  def get_primaries_key(table) do
    table
    |> list_columns()
    |> Enum.filter(fn [_, _, _, primary, _, _] ->
      primary == "PRI"
    end)
    |> Enum.map(&("`#{hd(&1)}`" <> " ASC"))
    |> Enum.join(", ")
  end

  def count(table) do
    {:ok, %MyXQL.Result{rows: [[count]]}} =
      MyXQL.query(@repo, "SELECT COUNT(*) FROM `#{table}`")

    count
  end

  def paginate(table, primaries, offset, fun) do
    {:ok, %MyXQL.Result{columns: columns, rows: rows, num_rows: count}} =
      MyXQL.query(
        @repo,
        "SELECT * FROM `#{table}` ORDER BY #{primaries} LIMIT #{@page_size} OFFSET #{offset}"
      )

    fun.(columns, rows)

    if count < @page_size,
      do: :ok,
      else: paginate(table, primaries, offset + @page_size, fun)
  end
end
