defmodule ExGoPiGo.Mixfile do
  use Mix.Project

  def project do
    [app: :exgopigo,
     version: "0.0.1",
     name: "ExGoPiGo",
     source_url: "https://github.com/infinitenil/exgopigo",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: escript_config,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      { :elixir_ale,      "~> 0.3.0" },
      { :ex_doc,          github: "elixir-lang/ex_doc" },
      { :"erlang-serial", github: "knewter/erlang-serial" }
    ]
  end

  defp escript_config do
    [main_module: ExGoPiGo]
  end

end

