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

  def blink(0) do
  end

  def blink(count) do
    turnOnLeftLED()
    turnOnRightLED()
    :timer.sleep(500)

    turnOffLeftLED()
    turnOffRightLED()
    :timer.sleep(500)

    blink(count - 1)
  end

  def turnOffLeftLED() do
    setLED(@led_left_pin, 0)
  end

  def turnOffRightLED() do
    setLED(@led_right_pin, 0)
  end

  def turnOnLeftLED() do
    setLED(@led_left_pin, 1)
  end

  def turnOnRightLED() do
    setLED(@led_right_pin, 1)
  end

  defp setLED(led, on) do
    Board.digital_write(led, on)
  end

end
