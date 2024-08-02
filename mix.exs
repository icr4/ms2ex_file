defmodule Ms2exFile.MixProject do
  use Mix.Project

  def project do
    [
      app: :ms2ex_file,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Ms2exFile.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:myxql, "~> 0.7.0"},
      {:redix, "~> 1.1"}
    ]
  end
end
