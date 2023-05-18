defmodule Forager do
  alias Forager.{Brain, Game, Player, Scripts}

  def demo do
    p1 =
      Player.new("dog") |> Map.put(:brain, Brain.from_elixir(Scripts.get("nearest_walker.lua")))

    p2 =
      Player.new("cat") |> Map.put(:brain, Brain.from_elixir(Scripts.get("biggest_walker.lua")))

    Game.new(11, 11)
    |> Game.add_player(p1)
    |> Game.add_player(p2)
    |> Game.advance_round()
  end
end
