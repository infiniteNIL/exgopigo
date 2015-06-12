defmodule ExGoPiGo.UltraSonicSensor do
	alias ExGoPiGo.Board
	require Logger

	@us_cmd			117	# Read the distance from the ultrasonic sensor
	@sensor_pin	15

	# Read ultrasonic sensor
	#	return:		distance in cm
	def distance() do
		Board.write_i2c_block(<<@us_cmd, @sensor_pin, 0, 0>>)
		:timer.sleep(80)
		try do
			<<b1>> = Board.read(1)
			<<b2>> = Board.read(1)
			if b1 != -1 and b2 != -1 do
				v = b1 * 256 + b2
			else
				-1
			end
		rescue 
				IOError -> IO.puts "IOError"; -1
		end
	end

end