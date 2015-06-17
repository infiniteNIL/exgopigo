defmodule ExGoPiGo.Servo do
	alias ExGoPiGo.Board
	require Logger

  @dis_servo_cmd  60  # Disable the servo's
  @en_servo_cmd   61  # Enable the servo's
  @servo_cmd			101	# Rotate the servo

	# Set servo position
	#	arg:
	#		position: angle in degrees to set the servo at
	def turn_to_degrees(degrees) do
		Logger.debug "Turning servo to #{degrees} degrees."
		Board.write_i2c_block(<<@servo_cmd, degrees, 0, 0>>)
	end

	#Enables the servo
	def enable_servo() do
		Board.write_i2c_block(<<@en_servo_cmd, 0, 0, 0>>)
	end

	# Disable the servo
	def disable_servo() do
		Board.write_i2c_block(<<@dis_servo_cmd, 0, 0, 0>>)
	end

end