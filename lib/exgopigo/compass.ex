defmodule ExGoPiGo.Compass do
	use GenServer
	use Bitwise

	require Logger

	@hmc5883l_address 0x1E

	#CONFIGURATION_REGISTERA     =0x00
	#CONFIGURATION_REGISTERB     =0x01
	@mode_register 		0x02
	#DATA_REGISTER_BEGIN         =0x03

	@continuous_measurement 0x00
	#MEASUREMENT_SINGLE_SHOT     =0x01
	#MEASUREMENT_IDLE            =0x03

	#####
	# External API

	@doc """
	Initialize the compass
	"""
	def start_link() do
		GenServer.start_link(__MODULE__, [], name: __MODULE__)
	end

	@doc """
	Get the compass heading in degrees
	"""
	def heading() do
		GenServer.call __MODULE__, :heading
	end

	#####
	# GenServer Implementation

	def init(_) do
		Logger.info "Establishing link to compass."
    {:ok, pid} = I2c.start_link("i2c-1", @hmc5883l_address)

    # Set the compass to continuos measurment
    I2c.write(pid, <<@mode_register, @continuous_measurement>>)
    :timer.sleep(100)
    { :ok, pid }
  end

	def handle_call(:heading, _from, compass_pid) do
		{ :reply, read_heading(compass_pid), compass_pid }
	end

	# Update the compass values
	defp read_heading(pid) do
		{ x, y } = read_heading_data(pid)

		heading = :math.atan2(y, x)
		if heading < 0, do:	heading = heading + :math.pi()
		if heading > :math.pi(), do: heading = heading - 2 * :math.pi()
		
		Float.round(degrees(heading), 2)
	end

	defp read_heading_data(pid) do
		I2c.write(pid, <<0x00>>)	# start reading from register 0
		data = I2c.read(pid, 9)
		<<data3>> = binary_part(data, 3, 1)
		<<data4>> = binary_part(data, 4, 1)
		# <<data5>> = binary_part(data, 5, 1)
		# <<data6>> = binary_part(data, 6, 1)
		<<data7>> = binary_part(data, 7, 1)
		<<data8>> = binary_part(data, 8, 1)

		x = twos_complement(data3 * 256 + data4, 16)
		# _z = twos_complement(data5 * 256 + data6, 16)
		y = twos_complement(data7 * 256 + data8, 16)
		{ x, y }
	end

	# Do two's compiment of val (for parsing the input)
	# http://stackoverflow.com/a/9147327/1945052
	defp twos_complement(val, bits) do
		if (val &&& (1 <<< (bits - 1))) != 0 do
			val - (1 <<< bits)
		else 
			val
		end
	end

	defp degrees(radians) do 
		radians * 180 / :math.pi()
	end

end
