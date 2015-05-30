defmodule ExGoPiGo.Brain do
	alias ExGoPiGo.Board
	alias ExGoPiGo.LEDs
	alias ExGoPiGo.Servo
	alias ExGoPiGo.UltraSonicSensor
	require Logger

	@moduledoc """
	The brain for our robot. Controls and responds to all the sensors, motors, etc.
	"""

	@doc """
	Initialize the robot's brain.

	Return the process ID for the GoPiGoBoard
	"""
	def init() do
		Board.init()
	end

	@doc """
	The control loop for our robot. Continuously waits for sensor messages and responds to them.
	"""
	def run(pid) do
		LEDs.turnOnLeftLED(pid)
		:timer.sleep(1000)
		LEDs.turnOffLeftLED(pid)
		:timer.sleep(1000)
		LEDs.turnOnRightLED(pid)
		:timer.sleep(1000)
		LEDs.turnOffRightLED(pid)

		# Servo.turn_to_degrees(pid, 0)
		# :timer.sleep(1000)
		# Servo.turn_to_degrees(pid, 180)
		# :timer.sleep(1000)
		# Servo.turn_to_degrees(pid, 90)
		# :timer.sleep(500)

		test_servo(pid, 0)

		Logger.info "Distance is #{UltraSonicSensor.distance(pid)} cm."
	end

	def test_servo(pid, degrees) do
		Servo.turn_to_degrees(pid, degrees)
		:timer.sleep(250)
		if degrees + 30 <= 180 do
			test_servo(pid, degrees + 30)
		end
	end

end
