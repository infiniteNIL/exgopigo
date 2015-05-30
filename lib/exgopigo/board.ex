defmodule ExGoPiGo.Board do
	require Logger
	use Bitwise

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

  # Returns the firmware version
	def firmware_version(pid) do
		write_i2c_block(pid, <<@fw_ver_cmd, 0, 0, 0>>)
		:timer.sleep(100)
		try do
			<<version>> = I2c.read(pid, 1)
			I2c.read(pid, 1)	# Empty the buffer
			version / 10
		rescue 
			IOError -> IO.puts "IOError"; -1
		end
	end

	# Read voltage
	#	return:	voltage in V
	def voltage(pid) do
		write_i2c_block(pid, <<@volt_cmd, 0, 0, 0>>)
		:timer.sleep(100)
		try do
			<<b1>> = I2c.read(pid, 1)
			<<b2>> = I2c.read(pid, 1)
			if b1 != -1 and b2 != -1 do
				v = b1 * 256 + b2
				v = (5 * v / 1024) / 0.4
				Float.round(v, 2)
			else
				-1
			end
		rescue 
			IOError -> IO.puts "IOError"; -1
		end
	end

	# Read the status register on the GoPiGo
	#	Gets a byte, b0 - enc_status
	#							 b1 - timeout_status
	#	Return:	list with
	#						l[0] - enc_status
	#						l[1] - timeout_status
	def read_status(pid) do
		<<st>> = I2c.read(pid, 1)
		{st &&& 0x01, div(st &&& 0x02, 2)}
	end
		 
	# Read encoder status
	#	return:	0 if encoder target is reached
	def read_encoder_status(pid) do
		st = read_status(pid)
		elem(st, 0)
	end

	# Read timeout status
	#	return:	0 if timeout is reached
	def read_timeout_status(pid) do
		st = read_status(pid)
		elem(st, 1)
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
  def write_i2c_block(pid, block) do
    try do
      :ok = I2c.write(pid, block)
      true	# 1
    rescue
      IOError -> IO.puts "IOError"; false # -1
    end
  end

end
