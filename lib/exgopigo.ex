defmodule ExGoPiGo do
  alias ExGoPiGo.Brain

  # GoPiGo Commands
  @fwd_cmd				      119	# Move forward with PID
  @motor_fwd_cmd        105	# Move forward without PID
  @bwd_cmd              115	# Move back with PID
  @motor_bwd_cmd        107	# Move back without PID
  @left_cmd             97	# Turn Left by turning off one motor
  @left_rot_cmd		      98	# Rotate left by running both motors is opposite direction
  @right_cmd            100	# Turn Right by turning off one motor
  @right_rot_cmd	      110	# Rotate Right by running both motors is opposite direction
  @stop_cmd             120	# Stop the GoPiGo
  @ispd_cmd             116	# Increase the speed by 10
  @dspd_cmd             103	# Decrease the speed by 10
  @m1_cmd      		      111 # Control motor1
  @m2_cmd               112 # Control motor2

  @volt_cmd	            118 # Read the voltage of the batteries
  @us_cmd				        117 # Read the distance from the ultrasonic sensor
  @led_cmd              108 # Turn On/Off the LED's
  @servo_cmd            101 # Rotate the servo
  @enc_tgt_cmd			    50  # Set the encoder targeting
  @fw_ver_cmd		        20  # Read the firmware version
  @en_enc_cmd		        51  # Enable the encoders
  @dis_enc_cmd			    52  # Disable the encoders
  @read_enc_status_cmd  53  # Read encoder status
  @en_servo_cmd         61  # Enable the servo's
  @dis_servo_cmd        60  # Disable the servo's
  @set_left_speed_cmd   70  # Set the speed of the right motor
  @set_right_speed_cmd  71  # Set the speed of the left motor
  @en_com_timeout_cmd   80  # Enable communication timeout
  @dis_com_timeout_cmd  81  # Disable communication timeout
  @timeout_status_cmd   82  # Read the timeout status
  @enc_read_cmd		      53  # Read encoder values
  @trim_test_cmd        30  # Test the trim values
  @trim_write_cmd		    31  # Write the trim values
  @trim_read_cmd        32

  def main() do
    # TODO: Better way to manage state (pid)
    pid = setup()
    run(pid)
    cleanup(pid)
  end

  defp setup() do
    # TODO: Treat Brain as an app (i.e. automatically started in mix.exs)
    Brain.init()
  end

  defp run(pid) do
    Brain.run(pid)
  end

  defp cleanup(pid) do
  end

end
