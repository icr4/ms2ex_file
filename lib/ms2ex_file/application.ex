defmodule Ms2exFile.Application do
  use Application

  @impl true
  def start(_type, _args) do
    myxql =
      Application.fetch_env!(:ms2ex_file, :mysql_uri)
      |> Ms2exFile.MySql.parse_uri()
      |> Keyword.put(:name, :myxql)

    redix =
      Application.fetch_env!(:ms2ex_file, :redis_uri)
      |> Redix.URI.to_start_options()
      |> Keyword.put(:name, :redix)

    children = [
      {MyXQL, myxql},
      {Redix, redix}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Ms2exFile.Supervisor)
  end
end
