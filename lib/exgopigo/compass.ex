defmodule ExGoPiGo.Compass do
	require Logger
	use Bitwise

	@hmc5883l_address 0x1E

	#CONFIGURATION_REGISTERA     =0x00
	#CONFIGURATION_REGISTERB     =0x01
	@mode_register 		0x02
	#DATA_REGISTER_BEGIN         =0x03

	@continuous_measurement 0x00
	#MEASUREMENT_SINGLE_SHOT     =0x01
	#MEASUREMENT_IDLE            =0x03

	#Compass class for all the values and functions
	# class compass:
	# 	x=0
	# 	y=0
	# 	z=0
	# 	heading=0
	# 	headingDegrees=0
	
	def init() do
		Logger.info "Establishing link to compass."
    {:ok, pid} = I2c.start_link("i2c-1", @hmc5883l_address)
    # Set the compass to continuos measurment
    I2c.write(pid, <<@mode_register, @continuous_measurement>>)
    :timer.sleep(100)
    pid
  end

	# def init(pid) do
	# 	# Enable the compass
	# 	Board.write_i2c_block(pid, <<@hmc5883l_address, @mode_register, 0>>)
	# 	# I2c.write_byte_data(@hmc5883l_address, @mode_register, 0)
	# 	:timer.sleep(100)
	# 	# data = I2c.read_i2c_block_data(@hmc5883l_address, 0)
	# 	_data = Board.read_i2c_block(pid, 9)
	# 	update(pid)
	# end
	
	# Update the compass values
	def update(pid) do
		# data = I2c.read_i2c_block_data(@hmc5883l_address, 0)
		##data = Board.read_i2c_block(pid, 9)
		I2c.write(pid, <<0x00>>)	# start reading from register 0
		data = I2c.read(pid, 9)
		# compass.x = twos_complement(data[3] * 256 + data[4], 16)
		# compass.z = twos_complement(data[5] * 256 + data[6], 16)
		# compass.y = twos_complement(data[7] * 256 + data[8], 16)
		# compass.heading = math.atan2(compass.y, compass.x)
		# if compass.heading < 0, do:	compass.heading += 2 * math.pi
		# if compass.heading > 2 * math.pi, do: compass.heading -= 2 * math.pi
		
		# compass.headingDegrees = round(math.degrees(compass.heading),2)

		<<data3>> = binary_part(data, 3, 1)
		<<data4>> = binary_part(data, 4, 1)
		<<data5>> = binary_part(data, 5, 1)
		<<data6>> = binary_part(data, 6, 1)
		<<data7>> = binary_part(data, 7, 1)
		<<data8>> = binary_part(data, 8, 1)

		x = twos_complement(data3 * 256 + data4, 16)
		_z = twos_complement(data5 * 256 + data6, 16)
		y = twos_complement(data7 * 256 + data8, 16)

		heading = :math.atan2(y, x)
		if heading < 0, do:	heading = heading + :math.pi()
		if heading > :math.pi(), do: heading = heading - 2 * :math.pi()
		
		_headingDegrees = Float.round(radians_to_degrees(heading), 2)
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

	defp radians_to_degrees(radians) do 
		radians * 180 / :math.pi()
	end

end
