defmodule ExGoPiGo.LEDs do
	alias ExGoPiGo.Board

	@moduledoc """
	Controls the 2 LEDs on the GoPiGo
	"""

	# TODO: Treat LEDs as an app? (i.e. separate process)

  @led_cmd  108 # Turn On/Off the LED's // TODO: Unused

 	# LED Pins
  @led_left_pin   10
  @led_right_pin  5

  # LED setup
  @led_left  1
  @led_right 0

  def turnOffLeftLED(pid) do
    setLED(pid, @led_left_pin, 0)
  end

  def turnOffRightLED(pid) do
    setLED(pid, @led_right_pin, 0)
  end

  def turnOnLeftLED(pid) do
    setLED(pid, @led_left_pin, 1)
  end

  def turnOnRightLED(pid) do
    setLED(pid, @led_right_pin, 1)
  end

  defp setLED(pid, led, on) do
    # I2c.write(pid, <<@digital_write_cmd, led, on, 0>>)
    Board.digitalWrite(pid, led, on)
  end

end
