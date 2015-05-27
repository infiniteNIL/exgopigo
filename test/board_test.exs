defmodule BoardTest do
	use ExUnit.Case

	alias ExGoPiGo.Board

	test "Can initialize the board" do
		assert Board.init() != nil
	end

end