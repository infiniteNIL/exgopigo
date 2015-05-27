defmodule ExGoPiGo.Brain do
	alias ExGoPiGo.Board
	alias ExGoPiGo.LEDs

	def init() do
		Board.init()
	end

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
