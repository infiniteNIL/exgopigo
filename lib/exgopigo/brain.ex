defmodule ExGoPiGo.Brain do
	use GenServer

	alias ExGoPiGo.Board
	alias ExGoPiGo.LEDs
	alias ExGoPiGo.Servo
	alias ExGoPiGo.UltraSonicSensor
	alias ExGoPiGo.Compass
	alias ExGoPiGo.Motors
	alias ExGoPiGo.GPS

	require Logger

	@moduledoc """
	The brain for our robot. Controls and responds to all the sensors, motors, etc.
	"""

	#####
	# External API

	@doc """
	Initialize the Brain
	"""
	def start_link() do
		GenServer.start_link(__MODULE__, [], name: __MODULE__)
	end

	############
	# GenServer Implementation

	@doc """
	Initialize the robot's brain.

	Return the process ID for the GoPiGoBoard
	"""
	def init(_) do
		Logger.info "Exy is starting up."
		{ :ok, _ } = Board.start_link()
		{ :ok, _ } = Compass.start_link()
		{ :ok, _ } = GPS.start_link()
		status_report()
		{ :ok, [] }
	end

  defp status_report() do
    Logger.info "GoPiGo Firmware v#{Board.firmware_version()}"
    Logger.info "Power: #{Board.voltage()} volts"
    Logger.info "Encoder Status: #{Board.read_encoder_status()}"
    Logger.info "Timeout Status: #{Board.read_timeout_status()}"
    {lat, long} = GPS.location()
    Logger.info "GPS Location: #{lat}, #{long}"
    Logger.info "Heading: #{Compass.heading} degrees."
		Logger.info "Distance: #{UltraSonicSensor.distance()} cm."
  end

	@doc """
	Start the control loop for our robot. Continuously waits for sensor messages and responds to them.
	Returns the pid of the background run loop task
	"""
  def run() do
  	run_loop()
  	shutdown()
  end

	defp run_loop() do
		Motors.stop()
		LEDs.blink(2)
		shake_head(2)
		dance()
	end

  defp shake_head(0) do
		Servo.turn_to_degrees(90)
		:timer.sleep(500)
  end

  defp shake_head(count) do
		Servo.turn_to_degrees(60)
		:timer.sleep(500)
		Servo.turn_to_degrees(120)
		:timer.sleep(500)

		shake_head(count - 1)
  end

  defp dance() do
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
  	#Motors.right_rotate()
  	#:timer.sleep(2000)
  	# rotate_until(pid, heading)

  	Motors.stop()
  end

  defp rotate_until(pid, heading) do
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

	defp test_servo(degrees) do
		Servo.turn_to_degrees(degrees)
		:timer.sleep(250)
		if degrees + 30 <= 180 do
			test_servo(degrees + 30)
		end
	end

	defp shutdown() do
		Logger.info "Exy is shutting down."
	end

end
