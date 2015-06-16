defmodule ExGoPiGo do
  alias ExGoPiGo.Brain
  require Logger

  # GoPiGo Commands

  def main(_argv) do
    setup()
    run()
    cleanup()
  end

  defp setup() do
    # TODO: Treat Brain as an app (i.e. automatically started in mix.exs)
    Logger.info "Exy is starting up."
    Brain.start_link()
  end

  defp run() do
    Brain.run()
  end

  defp cleanup() do
    Logger.info "Exy is shutting down."
  end

end
