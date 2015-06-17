defmodule ExGoPiGo do
  use Application
  alias ExGoPiGo.Brain

  def start(_type, _args) do
    {:ok, _pid} = Brain.start_link()
    Task.start_link(&Brain.run/0)
  end

end
