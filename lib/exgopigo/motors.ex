defmodule ExGoPiGo.Motors do
	require Logger
	alias ExGoPiGo.Board

  @trim_test_cmd  			30  # Test the trim values
  @trim_write_cmd 			31  # Write the trim values
  @trim_read_cmd  			32
  @enc_tgt_cmd			    50  # Set the encoder targeting
  @en_enc_cmd     			51  # Enable the encoders
  @dis_enc_cmd   				52  # Disable the encoders
  @enc_read_cmd   			53  # Read encoder values
  @set_left_speed_cmd   70  # Set the speed of the right motor
  @set_right_speed_cmd	71  # Set the speed of the left motor
  @en_com_timeout_cmd   80  # Enable communication timeout
  @dis_com_timeout_cmd  81  # Disable communication timeout
  @left_cmd       			97	# Turn Left by turning off one motor
  @left_rot_cmd   			98	# Rotate left by running both motors is opposite direction
  @right_cmd      			100	# Turn Right by turning off one motor
  @dspd_cmd       			103	# Decrease the speed by 10
  @motor_fwd_cmd				105	# Move forward without PID
  @motor_bwd_cmd  			107	# Move back without PID
  @right_rot_cmd  			110	# Rotate Right by running both motors is opposite direction
  @m1_cmd								111	# Control motor1
  @m2_cmd								112 # Control motor2
  @bwd_cmd              115	# Move back with PID
  @ispd_cmd       			116	# Increase the speed by 10
  @fwd_cmd				      119	# Move forward with PID
  @stop_cmd       			120	# Stop the GoPiGo

	# Control Motor 1
	def motor1(pid, direction, speed) do
		Board.write_i2c_block(pid, <<@m1_cmd, direction, speed, 0>>)
	end
		
	# Control Motor 2
	def motor2(pid, direction, speed) do
		Board.write_i2c_block(pid, <<@m2_cmd, direction, speed, 0>>)
	end
		
	# Move the GoPiGo forward
	def forward() do
		Board.write_i2c_block(<<@motor_fwd_cmd, 0, 0, 0>>)
	end
		
	# Move the GoPiGo forward without PID
	def motor_forward(pid) do
		Board.write_i2c_block(pid, <<@motor_fwd_cmd, 0, 0, 0>>)
	end

	# Move GoPiGo back
	def backward() do
		Board.write_i2c_block(<<@motor_bwd_cmd, 0, 0, 0>>)
	end

	# Move GoPiGo back without PID control
	def motor_backward(pid) do
		Board.write_i2c_block(pid, <<@motor_bwd_cmd, 0, 0, 0>>)
	end

	# Turn GoPiGo Left slow (one motor off, better control)	
	def left(pid) do
		Board.write_i2c_block(pid, <<@left_cmd, 0, 0, 0>>)
	end

	#Rotate GoPiGo left in same position (both motors moving in the opposite direction)
	def left_rotate(pid) do
		Board.write_i2c_block(pid, <<@left_rot_cmd, 0, 0, 0>>)
	end

	# Turn GoPiGo right slow (one motor off, better control)
	def right(pid) do
		Board.write_i2c_block(pid, <<@right_cmd, 0, 0, 0>>)
	end

	# Rotate GoPiGo right in same position both motors moving in the opposite direction)
	def right_rotate() do
		Board.write_i2c_block(<<@right_rot_cmd, 0, 0, 0>>)
	end

	# Stop the GoPiGo
	def stop() do
		Board.write_i2c_block(<<@stop_cmd, 0, 0, 0>>)
	end
		
	# Increase the speed
	def increase_speed(pid) do
		Board.write_i2c_block(pid, <<@ispd_cmd, 0, 0, 0>>)
	end
		
	# Decrease the speed
	def decrease_speed(pid) do
		Board.write_i2c_block(pid, <<@dspd_cmd, 0, 0, 0>>)
	end

	# Trim test with the value specified
	def trim_test(pid, value) do
		if value > 100 do
			value = 100
		else 
			if value < -100, do: value = -100
		end
		value = value + 100
		Board.write_i2c_block(pid, <<@trim_test_cmd, value, 0, 0>>)
	end

	# Read the trim value in	EEPROM if present else return -3
	def trim_read(pid) do
		Board.write_i2c_block(pid, <<@trim_read_cmd, 0, 0, 0>>)
		:timer.sleep(80)
		try do
			<<b1>> = I2c.read(pid, 1)
			<<b2>> = I2c.read(pid, 1)
			if b1 != -1 and b2 != -1 do
				v = b1 * 256 + b2
				if v == 255 do
					-3
				else
					v
				end
			else
				-1
			end
		rescue 
			IOError -> -1
		end			
	end
			
	# Write the trim value to EEPROM, where -100=0 and 100=200
	def trim_write(pid, value) do
		if value > 100 do
			value = 100
		else 
			if value < -100, do: value = -100
		end
		value = value + 100
		Board.write_i2c_block(pid, <<@trim_write_cmd, value, 0, 0>>)
	end

	# Set encoder targeting on
	# arg:
	#	 m1: 0 to disable targeting for m1, 1 to enable it
	#	 m2:	1 to disable targeting for m2, 1 to enable it
	#	target: number of encoder pulses to target (18 per revolution)
	def encoder_target(pid, m1, m2, target) do
		if m1 > 1 or m1 < 0 or m2 > 1 or m2 < 0 do
			false # -1
		else
			m_sel = m1 * 2 + m2
			Board.write_i2c_block(pid, <<@enc_tgt_cmd, m_sel, div(target, 256), rem(target, 256)>>)
			true # 1
		end
	end

	#Read encoder value
	#	arg:
	#		motor -> 	0 for motor1 and 1 for motor2
	#	return:		distance in cm
	def encoder_read(pid, motor) do
		Board.write_i2c_block(pid, <<@enc_read_cmd, motor, 0, 0>>)
		:timer.sleep(80)
		try do
			<<b1>> = I2c.read(pid, 1)
			<<b2>> = I2c.read(pid, 1)
			if b1 != -1 and b2 != -1 do
				v = b1 * 256 + b2
				v
			else
				-1
			end
		rescue
			IOError -> -1
		end
	end

	# Enable the encoders (enabled by default)
	def enable_encoders(pid) do
		Board.write_i2c_block(pid, <<@en_enc_cmd, 0, 0, 0>>)
	end
		
	# Disable the encoders (use this if you don't want to use the encoders)
	def disable_encoders(pid) do
		Board.write_i2c_block(pid, <<@dis_enc_cmd, 0, 0, 0>>)
	end

	# Set speed of the left motor
	#	arg:
	#		speed-> 0-255
	def set_left_speed(pid, speed) do
		if speed > 255 do
			speed = 255
		else 
			if speed < 0, do: speed = 0
		end

		Board.write_i2c_block(pid, <<@set_left_speed_cmd, speed, 0, 0>>)
	end
		
	# Set speed of the right motor
	#	arg:
	#		speed-> 0-255
	def set_right_speed(pid, speed) do
		if speed > 255, do: speed = 255
		if speed < 0, do: speed = 0
		Board.write_i2c_block(pid, <<@set_right_speed_cmd, speed, 0, 0>>)
	end

	# Set speed of the both motors
	#	arg:
	#		speed-> 0-255
	def set_speed(pid, speed) do
		if speed > 255, do:	speed = 255
		if speed < 0, do: speed = 0

		set_left_speed(pid, speed)
		:timer.sleep(100)
		set_right_speed(pid, speed)
	end

	# Enable communication time-out(stop the motors if no command received in the specified time-out)
	#	arg:
	#		timeout-> 0-65535 (timeout in ms)
	def enable_com_timeout(pid, timeout) do
		Board.write_i2c_block(pid, <<@en_com_timeout_cmd, div(timeout, 256), rem(timeout, 256), 0>>) 
	end

	# Disable communication time-out
	def disable_com_timeout(pid) do
		Board.write_i2c_block(pid, <<@dis_com_timeout_cmd, 0, 0, 0>>)
	end

end
