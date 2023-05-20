defmodule Forager.Brain do
  alias Forager.{Sandbox, Scripts}

  def from_elixir(script) do
    Sandbox.init()
    |> Sandbox.add_function("random_int", &random_int/1)
    |> Sandbox.add_function("distance", &distance/1)
    |> Sandbox.add_function("nearest", &nearest/1)
    |> Sandbox.add_function("biggest", &biggest/1)
    |> Sandbox.add_function("towards", &towards/1)
    |> Sandbox.add_script(script)
  end

  def from_lua(script) do
    Sandbox.init()
    |> Sandbox.add_function("random_int", &random_int/1)
    |> Sandbox.add_script(Scripts.get("player.lua"))
    |> Sandbox.add_script(script)
  end

  def random_int([n]) do
    m = ceil(n)
    Enum.random(1..m)
  end

  def distance([item, from]) do
    abs(item["x"] - from["x"]) + abs(item["y"] - from["y"])
  end

  def nearest([items, from]) do
    %{"x" => x, "y" => y} = Map.new(from)

    items
    |> Map.new()
    |> Map.values()
    |> Enum.map(&Map.new/1)
    |> Enum.sort_by(fn target ->
      abs(target["x"] - x) + abs(target["y"] - y)
    end)
    |> hd()
  end

  def biggest([items]) do
    items
    |> Map.new()
    |> Map.values()
    |> Enum.map(&Map.new/1)
    |> Enum.sort_by(fn item -> item["value"] end, :desc)
    |> hd()
  end

  def towards([target, from]) do
    %{"x" => tx, "y" => ty} = Map.new(target)
    %{"x" => fx, "y" => fy} = Map.new(from)

    cond do
      tx < fx -> "west"
      tx > fx -> "east"
      ty < fy -> "north"
      ty > fy -> "south"
      true -> "here"
    end
  end
end
