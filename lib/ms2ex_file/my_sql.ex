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

  def count(table) do
    {:ok, %MyXQL.Result{rows: [[count]]}} =
      MyXQL.query(@repo, "SELECT COUNT(*) FROM `#{table}`")

    count
  end

  def paginate(table, offset, fun) do
    {:ok, %MyXQL.Result{columns: columns, rows: rows, num_rows: count}} =
      MyXQL.query(
        @repo,
        "SELECT * FROM `#{table}` LIMIT #{@page_size} OFFSET #{offset}"
      )

    fun.(columns, rows)

    if count < @page_size,
      do: :ok,
      else: paginate(table, offset + @page_size, fun)
  end
end
