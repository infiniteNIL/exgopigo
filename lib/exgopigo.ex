defmodule ExGoPiGo do
  alias ExGoPiGo.Brain
  require Logger

  # GoPiGo Commands

  def main(_argv) do
    # TODO: Better way to manage state (pid)
    pid = setup()
    run(pid)
    cleanup(pid)
  end

  defp setup() do
    # TODO: Treat Brain as an app (i.e. automatically started in mix.exs)
    Logger.info "Exy is starting up."
    Brain.init()
  end

  defp run(pid) do
    Brain.run(pid)
  end

  defp cleanup(pid) do
    Logger.info "Exy is shutting down."
  end

end
