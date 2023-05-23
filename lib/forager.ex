defmodule Forager do
  alias Forager.{Brain, Game, Player, Scripts}

  def demo do
    p1 =
      Player.new("boar")
      |> Map.put(:brain, Brain.from_elixir(Scripts.get("nearest_walker.lua")))

    p2 =
      Player.new("coyote") |> Map.put(:brain, Brain.from_elixir(Scripts.get("biggest_walker.lua")))

    Game.new(11, 11)
    |> Game.add_player(p1)
    |> Game.add_player(p2)
    |> Game.advance_round()
  end

  def size_of_vm() do
    :luerl.init()
    |> :erlang.term_to_binary()
    |> :erlang.byte_size()
  end

  def delete_all_my_stuff(path) do
    File.rm_rf!(path)
  end

end
