defmodule ExGoPiGo do
  alias ExGoPiGo.Brain
  alias ExGoPiGo.Board
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
    pid = Brain.init()
    Logger.info "GoPiGo Firmware v#{Board.firmware_version(pid)}"
    Logger.info "Power: #{Board.voltage(pid)} volts"
    Logger.info "Status: #{Board.read_status(pid)}"
    Logger.info "Encoder Status: #{Board.read_encoder_status(pid)}"
    Logger.info "Timeout Status: #{Board.read_timeout_status(pid)}"
    pid
  end

  defp run(pid) do
    Brain.run(pid)
  end

  defp cleanup(pid) do
    Logger.info "Exy is shutting down."
  end

end
