defmodule Ms2exFile.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    myxql = Application.fetch_env!(:ms2ex_file, :myxql)
    redix = Application.fetch_env!(:ms2ex_file, :redix)

    children = [
      {
        MyXQL,
        hostname: myxql[:hostname],
        username: myxql[:username],
        password: myxql[:password],
        database: myxql[:database],
        port: myxql[:port],
        timeout: :infinity,
        name: :myxql
      },
      {
        Redix,
        host: redix[:host], name: :redix
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ms2exFile.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
