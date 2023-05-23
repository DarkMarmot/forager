defmodule Forager.Game do
  alias Forager.Game
  alias Forager.Player
  alias Forager.Fruit

  defstruct width: 0,
            height: 0,
            cx: 0,
            cy: 0,
            round: 0,
            players: [],
            fruits: [],
            view: nil,
            outcome: nil

  def new(width, height) do
    %Game{width: width, height: height}
    |> determine_center()
    |> place_fruits()
    |> update_view()
  end

  def determine_center(game) do
    %Game{game | cx: floor(game.width / 2), cy: floor(game.height / 2)}
  end

  def place_fruits(%Game{width: width, height: height, cx: cx, cy: cy} = game) do
    count = ceil(0.12 * width * height)

    fruits =
      1..count
      |> Enum.map(fn _ -> get_random_position(width, height) end)
      |> Enum.uniq()
      |> Enum.reject(fn {x, y} -> cx == x and cy == y end)
      |> Enum.map(fn {x, y} -> Fruit.new(x, y) end)

    %Game{game | fruits: fruits}
  end

  def get_random_position(width, height) do
    {Enum.random(1..width) - 1, Enum.random(1..height) - 1}
  end

  def update_view(%Game{players: players, fruits: fruits} = game) do
    view =
      game
      |> Map.take([:width, :height, :round, :cx, :cy])
      |> Map.put(:fruits, fruits |> Enum.reject(&Fruit.eaten?/1) |> Enum.map(&Fruit.to_view/1))
      |> Map.put(:players, Enum.map(players, &Player.to_view/1))

    %Game{game | view: view}
  end

  def advance_round(game) do
    %Game{game | round: game.round + 1}
    |> players_make_moves()
    |> fruits_are_bitten()
    |> fruits_are_scored()
    |> update_view()
  end

  def play_game(game) do
    if Game.game_over?(game) do
      game
    else
      game
      |> advance_round()
      |> play_game()
    end
  end

  def game_over?(game) do
    game.round > 100 or Enum.all?(game.fruits, & &1.eaten)
  end

  def players_make_moves(%Game{} = game) do
    players = Enum.map(game.players, &Player.make_move(&1, game))
    %Game{game | players: players}
  end

  def fruits_are_bitten(%Game{players: players, fruits: fruits} = game) do
    fruits_by_pos = Map.new(fruits, fn f -> {{f.x, f.y}, f} end)

    biters_by_fruit =
      players
      |> Enum.filter(&Player.biting?/1)
      |> Enum.map(fn p -> {p, fruits_by_pos[{p.x, p.y}]} end)
      |> Enum.reject(fn {_p, f} -> f == nil or f.eaten end)
      |> Enum.group_by(fn {_p, f} -> f end, fn {p, _f} -> p end)

    new_fruits = Enum.map(fruits, fn f -> %Fruit{f | biters: biters_by_fruit[f]} end)
    %Game{game | fruits: new_fruits}
  end

  def fruits_are_scored(%Game{players: players, fruits: fruits} = game) do
    bitten_fruits = Enum.filter(fruits, &is_list(&1.biters))

    scores_by_player_id =
      bitten_fruits
      |> Enum.flat_map(fn f ->
        score = floor(f.value / Enum.count(f.biters))
        Enum.map(f.biters, fn biter -> {biter.id, score} end)
      end)
      |> Map.new()

    new_fruits =
      fruits
      |> Enum.map(fn f ->
        if f.biters == nil, do: f, else: %Fruit{f | biters: nil, eaten: true}
      end)

    new_players =
      Enum.map(players, fn p ->
        case scores_by_player_id[p.id] do
          nil ->
            p
          score ->
            %Player{p | score: p.score + score}
        end
      end)

    %Game{game | players: new_players, fruits: new_fruits}
  end

  def reset_players(game) do
    %Game{game | players: Enum.map(game.players, fn player -> Player.reset(player) end)}
  end

  def reset_fruits(game) do
    %Game{game | fruits: Enum.map(game.fruits, fn fruit -> Fruit.reset(fruit) end)}
  end

  def add_player(game, player) do
    id = Enum.count(game.players)
    %Game{game | players: [%Player{player | id: id, x: game.cx, y: game.cy} | game.players]}
  end
end
