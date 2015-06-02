defmodule ExGoPiGo.Brain do
	alias ExGoPiGo.Board
	alias ExGoPiGo.LEDs
	alias ExGoPiGo.Servo
	alias ExGoPiGo.UltraSonicSensor
	alias ExGoPiGo.Compass
	alias ExGoPiGo.Motors

	require Logger

	@moduledoc """
	The brain for our robot. Controls and responds to all the sensors, motors, etc.
	"""

	@doc """
	Initialize the robot's brain.

	Return the process ID for the GoPiGoBoard
	"""
	def init() do
		{ :ok, pid } = Board.start_link()
		Compass.start_link()
		pid
	end

	@doc """
	The control loop for our robot. Continuously waits for sensor messages and responds to them.
	"""
	def run(pid) do
		status_report(pid)
		LEDs.blink(2)
		shake_head(pid, 2)
		# dance(pid)
	end

  def status_report(pid) do
    Logger.info "GoPiGo Firmware v#{Board.firmware_version()}"
    Logger.info "Power: #{Board.voltage()} volts"
    Logger.info "Encoder Status: #{Board.read_encoder_status()}"
    Logger.info "Timeout Status: #{Board.read_timeout_status()}"
    Logger.info "Heading: #{Compass.heading} degrees."
		Logger.info "Distance: #{UltraSonicSensor.distance(pid)} cm."
  end

  def shake_head(pid, 0) do
		Servo.turn_to_degrees(pid, 90)
		:timer.sleep(500)
  end

  def shake_head(pid, count) do
		Servo.turn_to_degrees(pid, 60)
		:timer.sleep(500)
		Servo.turn_to_degrees(pid, 120)
		:timer.sleep(500)

		shake_head(pid, count - 1)
  end

  def dance(pid) do
  	Motors.forward(pid)
  	:timer.sleep(500)
  	Motors.backward(pid)
  	:timer.sleep(500)

  	Motors.forward(pid)
  	:timer.sleep(500)
  	Motors.backward(pid)
  	:timer.sleep(500)

  	# heading = Compass.heading
  	# Logger.info "Starting heading: #{heading}"
  	Motors.right_rotate(pid)
  	:timer.sleep(2000)
  	# rotate_until(pid, heading)

  	Motors.stop(pid)
  end

  def rotate_until(pid, heading) do
  	:timer.sleep(500)
  	current = Compass.heading
  	Logger.info "Current heading: #{current}"
  	if abs(current - heading) < 5.0 do
  		Logger.info "Reached heading #{heading} degrees"
  		Motors.stop(pid)
  	else
  		rotate_until(pid, heading)
  	end
	end

	def test_servo(pid, degrees) do
		Servo.turn_to_degrees(pid, degrees)
		:timer.sleep(250)
		if degrees + 30 <= 180 do
			test_servo(pid, degrees + 30)
		end
	end

end
