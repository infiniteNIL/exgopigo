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
		shake_head(2)
		dance()
	end

  def status_report(pid) do
    Logger.info "GoPiGo Firmware v#{Board.firmware_version()}"
    Logger.info "Power: #{Board.voltage()} volts"
    Logger.info "Encoder Status: #{Board.read_encoder_status()}"
    Logger.info "Timeout Status: #{Board.read_timeout_status()}"
    Logger.info "Heading: #{Compass.heading} degrees."
		Logger.info "Distance: #{UltraSonicSensor.distance(pid)} cm."
  end

  def shake_head(0) do
		Servo.turn_to_degrees(90)
		:timer.sleep(500)
  end

  def shake_head(count) do
		Servo.turn_to_degrees(60)
		:timer.sleep(500)
		Servo.turn_to_degrees(120)
		:timer.sleep(500)

		shake_head(count - 1)
  end

  def dance() do
  	Motors.forward()
  	:timer.sleep(500)
  	Motors.backward()
  	:timer.sleep(500)

  	Motors.forward()
  	:timer.sleep(500)
  	Motors.backward()
  	:timer.sleep(500)

  	# heading = Compass.heading
  	# Logger.info "Starting heading: #{heading}"
  	Motors.right_rotate()
  	:timer.sleep(2000)
  	# rotate_until(pid, heading)

  	Motors.stop()
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

	def test_servo(degrees) do
		Servo.turn_to_degrees(degrees)
		:timer.sleep(250)
		if degrees + 30 <= 180 do
			test_servo(degrees + 30)
		end
	end

end
