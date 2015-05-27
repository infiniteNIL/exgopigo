defmodule ExGoPiGo.Brain do
	alias ExGoPiGo.Board
	alias ExGoPiGo.LEDs

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
	end

end
