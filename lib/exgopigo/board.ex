defmodule ExGoPiGo.Board do
	require Logger

	@moduledoc """
	Handles communicating with the GoPiGo board.
	"""

  # The device's address.
  @gopigo_board_address 0x08

  @read_enc_status_cmd  53  # Read encoder status 		TODO: unused
  @timeout_status_cmd   82  # Read the timeout status TODO: unused

  @digital_write_cmd    12  # Digital write on a port
  @digital_read_cmd     13  # Digital read on a port
  @analog_read_cmd      14  # Analog read on a port
  @analog_write_cmd     15  # Analog read on a port
  @pin_mode_cmd         16  # Set up the pin mode on a port

  @fw_ver_cmd		        20  # Read the firmware version
  @volt_cmd	            118 # Read the voltage of the batteries

  # This allows us to be more specific about which commands contain unused bytes
  @unused 0

  # The output mode for the pin.
  @pin_mode_output 1

  # The input mode for the pin.
  @pin_mode_input 0

  @doc """
  Initialize communications with the GoPiGoBoard.

  Return the process ID for the I2C process of the board
  """
	def init() do
		Logger.info "Establishing link to I2C port on GoPiGo board."
    {:ok, pid} = I2c.start_link("i2c-1", @gopigo_board_address)
    pid
  end

  # Arduino Digital Write
  def digitalWrite(pid, pin, value) when pin in [0, 1, 5, 10, 15] and value in [0, 1] do
    write_i2c_block(pid, <<@digital_write_cmd, pin, value, @unused>>)
    :timer.sleep(5)	# Wait for 5 ms for the commands to complete
    true  # 1
  end

  def digitalWrite(_, _, _) do
    # value is not 0 or 1
    false # -2
  end

  # Write I2C block
  defp write_i2c_block(pid, block) do
    try do
      :ok = I2c.write(pid, block)
    rescue
      IOError -> IO.puts "IOError"; false # -1
    end
    true  # 1
  end

end
