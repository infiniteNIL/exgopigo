defmodule ExGoPiGo do

  @moduledoc """
  Controls the GoPiGo board
  """

  # The device's address.
  @gopigo_board_address 0x08

  # GoPiGo Commands
  @fwd_cmd				 119	# Move forward with PID
  @motor_fwd_cmd  105	# Move forward without PID
  @bwd_cmd        115	# Move back with PID
  @motor_bwd_cmd  107	# Move back without PID
  @left_cmd       97		# Turn Left by turning off one motor
  @left_rot_cmd		 98		# Rotate left by running both motors is opposite direction
  @right_cmd			 100	# Turn Right by turning off one motor
  @right_rot_cmd	 110	# Rotate Right by running both motors is opposite direction
  @stop_cmd       120	# Stop the GoPiGo
  @ispd_cmd       116	# Increase the speed by 10
  @dspd_cmd       103	# Decrease the speed by 10
  @m1_cmd      		 111  # Control motor1
  @m2_cmd         112  # Control motor2

  @volt_cmd	             118 # Read the voltage of the batteries
  @us_cmd				         117 # Read the distance from the ultrasonic sensor
  @led_cmd              108 # Turn On/Off the LED's
  @servo_cmd            101 # Rotate the servo
  @enc_tgt_cmd			     50  # Set the encoder targeting
  @fw_ver_cmd		         20  # Read the firmware version
  @en_enc_cmd		         51  # Enable the encoders
  @dis_enc_cmd			     52  # Disable the encoders
  @read_enc_status_cmd  53  # Read encoder status
  @en_servo_cmd         61  # Enable the servo's
  @dis_servo_cmd        60  # Disable the servo's
  @set_left_speed_cmd   70  # Set the speed of the right motor
  @set_right_speed_cmd  71  # Set the speed of the left motor
  @en_com_timeout_cmd   80  # Enable communication timeout
  @dis_com_timeout_cmd  81  # Disable communication timeout
  @timeout_status_cmd   82  # Read the timeout status
  @enc_read_cmd		       53  # Read encoder values
  @trim_test_cmd        30  # Test the trim values
  @trim_write_cmd		     31  # Write the trim values
  @trim_read_cmd        32

  @digital_write_cmd  12  # Digital write on a port
  @digital_read_cmd   13  # Digital read on a port
  @analog_read_cmd    14  # Analog read on a port
  @analog_write_cmd   15  # Analog read on a port
  @pin_mode_cmd       16  # Set up the pin mode on a port

  # LED Pins
  @led_left_pin   10
  @led_right_pin  5

  # LED setup
  @led_left   1
  @led_right  0

  # This allows us to be more specific about which commands contain unused bytes
  @unused 0

  # The output mode for the pin.
  @pin_mode_output 1

  # The input mode for the pin.
  @pin_mode_input 0

  def init() do
    #{:ok, pid} = I2c.start_link("i2c-1", @gopigo_board_address)
    {:ok, pid} = I2c.start_link("i2c-1", @gopigo_board_address)
    pid
  end

  def turnOnRightLED(pid) do
    setLED(pid, @led_right_pin, 1)
  end

  def turnOffRightLED(pid) do
    setLED(pid, @led_right_pin, 0)
  end

  def turnOnLeftLED(pid) do
    setLED(pid, @led_left_pin, 1)
  end

  def turnOffLeftLED(pid) do
    setLED(pid, @led_left_pin, 0)
  end

  defp setLED(pid, led, on) do
    I2c.write(pid, <<@digital_write_cmd, led, on, 0>>)
    digitalWrite(pid, led, on)
  end

  # Arduino Digital Write
  defp digitalWrite(pid, pin, value) when pin in [0, 1, 5, 10, 15] and value in [0, 1] do
    write_i2c_block(pid, @gopigo_board_address, <<@digital_write_cmd, pin, value, @unused>>)
    :timer.sleep(5)	# Wait for 5 ms for the commands to complete
    true  # 1
  end

  defp digitalWrite(_, _, _) do
    # value is not 0 or 1
    false # -2
  end

  # Write I2C block
  defp write_i2c_block(pid, address, block) do
    try do
      {:reply, response, state} = I2c.write(pid, address, 1, block)
    rescue
      IOError -> IO.puts "IOError"; false # -1
    end
    true  # 1
  end


end
