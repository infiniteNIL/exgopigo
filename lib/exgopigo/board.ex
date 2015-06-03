defmodule ExGoPiGo.Board do
	use GenServer
	use Bitwise

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

  @firmware_version_cmd	20  # Read the firmware version
  @voltage_cmd          118 # Read the voltage of the batteries

  # This allows us to be more specific about which commands contain unused bytes
  @unused 0

  # The output mode for the pin.
  @pin_mode_output 1

  # The input mode for the pin.
  @pin_mode_input 0

 	#####
	# External API

	def start_link() do
		GenServer.start_link(__MODULE__, [], name: __MODULE__)
	end

	@doc """
	Get the GoPiGo's firmware version
	"""
	def firmware_version() do
		GenServer.call __MODULE__, :firmware_version
	end

	@doc """
	Get the voltage on the GoPiGo
	"""
	def voltage() do
		GenServer.call __MODULE__, :voltage
	end

	@doc """
	Read the status register on the GoPiGo
	Gets a byte, b0 - enc_status
							 b1 - timeout_status
	Return:	tuple { enc_status, timeout_status }
	"""
	def read_status() do
		GenServer.call __MODULE__, :read_status
	end

	@doc """
	Read encoder status
	return:	0 if encoder target is reached
	"""
	def read_encoder_status() do
		GenServer.call __MODULE__, :read_encoder_status
	end

	@doc """
	Read timeout status
	return:	0 if timeout is reached
	"""
	def read_timeout_status() do
		GenServer.call __MODULE__, :read_timeout_status
	end

	@doc """
	Arduino digital write
	"""
	def digital_write(pin, value) do
		GenServer.call(__MODULE__, { :digital_write, pin, value })
	end

	def read(count) do
		GenServer.call(__MODULE__, { :read, count })
	end

 	def write_i2c_block(block) do
 		GenServer.call(__MODULE__, { :write_i2c_block, block})
 	end

	#####
	# GenServer Implementation

  @doc """
  Initialize communications with the GoPiGoBoard.

  Return the process ID for the I2C process of the board
  """
	def init(_) do
		Logger.info "Establishing link to I2C port on GoPiGo board."
    I2c.start_link("i2c-1", @gopigo_board_address)
  end

  def handle_call(:firmware_version, _from, pid) do
		write_i2c_block(pid, <<@firmware_version_cmd, 0, 0, 0>>)
		:timer.sleep(100)
		<<version>> = I2c.read(pid, 1)
		I2c.read(pid, 1)	# Empty the buffer
		{ :reply, version / 10, pid }
	end

	def handle_call(:voltage, _from, pid) do
		write_i2c_block(pid, <<@voltage_cmd, 0, 0, 0>>)
		:timer.sleep(100)
		<<b1>> = I2c.read(pid, 1)
		<<b2>> = I2c.read(pid, 1)
		if b1 != -1 and b2 != -1 do
			v = b1 * 256 + b2
			v = (5 * v / 1024) / 0.4
			{ :reply, Float.round(v, 2), pid }
		else
			{ :reply, -1, pid }
		end
	end

	def handle_call(:read_status, _from, pid) do
		{ :reply, read_status(pid), pid }
	end

	def handle_call(:read_encoder_status, _from, pid) do
		st = read_status(pid)
		{ :reply, elem(st, 0), pid }
	end

	def handle_call(:read_timeout_status, _from, pid) do
		st = read_status(pid)
		{ :reply, elem(st, 1), pid }
	end

	def handle_call({:digital_write, pin, value}, _from, pid) do
		{ :reply, digitalWrite(pid, pin, value), pid }
	end
		 
	def handle_call({:write_i2c_block, block}, _from, pid) do
		{ :reply, write_i2c_block(pid, block), pid }
	end

	def handle_call({:read, count}, _from, pid) do
		{ :reply, I2c.read(pid, count), pid }
	end

	# Read the status register on the GoPiGo
	#	Gets a byte, b0 - enc_status
	#							 b1 - timeout_status
	#	Return:	list with
	#						l[0] - enc_status
	#						l[1] - timeout_status
	defp read_status(pid) do
		<<st>> = I2c.read(pid, 1)
		{st &&& 0x01, div(st &&& 0x02, 2)}
	end

  # Arduino Digital Write
  defp digitalWrite(pid, pin, value) when pin in [0, 1, 5, 10, 15] and value in [0, 1] do
    write_i2c_block(pid, <<@digital_write_cmd, pin, value, @unused>>)
    :timer.sleep(5)	# Wait for 5 ms for the commands to complete
    true  # 1
  end

  defp digitalWrite(_, _, _) do
    # value is not 0 or 1
    false # -2
  end

  defp read_i2c_block(pid, count) do
    try do
      I2c.read(pid, count)
    rescue
      IOError -> IO.puts "IOError"; 0
    end
  end

  # Write I2C block
  defp write_i2c_block(pid, block) do
    try do
      :ok = I2c.write(pid, block)
      true	# 1
    rescue
      IOError -> IO.puts "IOError"; false # -1
    end
  end

end
