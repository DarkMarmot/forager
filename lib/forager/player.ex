defmodule Forager.Player do
  alias Forager.Player

   defstruct id: 0,
            x: 0,
            y: 0,
            name: "",
            brain: nil,
            moves_by_round: %{},
            score: 0,
            round: 0,
            current_action: ""

  def new(name) do
    %Player{name: name}
  end

  def make_move(player, %{round: round, view: view} = _game) do
    move = Map.get(player.moves_by_round, round) || use_ai(player, view)
    new_moves_by_round = Map.put(player.moves_by_round, round, move)
    x = translate_x(player, view, move)
    y = translate_y(player, view, move)

    %Player{
      player
      | moves_by_round: new_moves_by_round,
        round: round,
        x: x,
        y: y,
        current_action: move
    }
  end

  def translate_x(player, view, action) do
    case action do
      "west" -> max(player.x - 1, 0)
      "east" -> min(player.x + 1, view.width - 1)
      _ -> player.x
    end
  end

  def translate_y(player, view, action) do
    case action do
      "north" -> max(player.y - 1, 0)
      "south" -> min(player.y + 1, view.height - 1)
      _ -> player.y
    end
  end

  def biting?(%{moves_by_round: moves_by_round} = player) do
    moves_by_round[player.round] == "bite"
  end

  def use_ai(player, view) do
    me = Map.take(player, [:id, :x, :y, :score])
    player_view = Map.put(view, :me, me)

    Sandbox.eval_function(player.brain, ["move"], [player_view])
    |> case do
      {:ok, %{result: [move]}} -> move
      {:error, _} -> "pass"
    end

  end

  def to_view(player) when is_list(player) do
    Enum.map(player, &to_view/1)
  end

  def to_view(player) do
    Map.take(player, [:id, :score, :x, :y, :name])
  end

  def reset(player) do
    %Player{player | score: 0, round: 0}
  end
end
