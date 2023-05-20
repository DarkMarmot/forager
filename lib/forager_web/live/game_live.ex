defmodule ForagerWeb.GameLive do
  use ForagerWeb, :live_view

  alias Forager.{Game, Player, Brain, Scripts}

  def mount(_params, _session, socket) do

    if connected?(socket), do: Process.send_after(self(), :update, 3000)

    # outcome or not
    # active or not

    w = 15
    h = 9

    p1 =
      Player.new("dog") |> Map.put(:brain, Brain.from_elixir(Scripts.get("nearest_walker.lua")))

    p2 =
      Player.new("cat") |> Map.put(:brain, Brain.from_elixir(Scripts.get("biggest_walker.lua")))

    game =
      Game.new(w, h)
      |> Game.add_player(p1)
      |> Game.add_player(p2)

    grass_tiles =
      for i <- 0..(w - 1), j <- 0..(h - 1) do
        %{x: i * 16, y: j * 16, v: get_grass_variant(8)}
      end

    {:ok, assign(socket, active: false, grass_tiles: grass_tiles, game: game)}
  end

  # def update(assigns, socket) do
  #   game = assigns.game
  #   {:ok, assign(socket, fruits: fruits)}
  # end

  defp get_grass_variant(max) do
    ceil(:rand.uniform() * :rand.uniform() * max)
  end

  def render(assigns) do

    ~H"""
    <div style={"padding: 10px; width: #{@game.width * 80 + 20}px; height: #{@game.height * 80 + 20}px;"}>
    <div style={"transform-origin: top left;position: relative; scale: 5; width: #{@game.width * 16}px; height: #{@game.height * 16}px; image-rendering: pixelated;"}>

    <%= for tile <- @grass_tiles do %>
        <div style={"position: absolute; left: #{tile.x}px; top: #{tile.y}px"}>
          <img src={"/images/g#{tile.v}.png"} height="16" width="16" />
        </div>
      <% end %>

      <%= for fruit <- @game.fruits do %>
        <.fruit fruit={fruit} />
      <% end %>

      <%= for player <- @game.players do %>
        <.player player={player} />
      <% end %>
    </div>
    </div>
    """
  end

  def fruit(assigns) do
    ~H"""
    <div style={"position: absolute; left: #{@fruit.x * 16}px; top: #{@fruit.y * 16}px; opacity: #{get_opacity(@fruit.eaten)}"}>
      <img src={"/images/f#{@fruit.type}.png"} height="16" width="16" />
    </div>
    """
  end

  def player(assigns) do
    ~H"""
    <div style={"z-index: #{@player.id}; position: absolute; transform: scaleX(1); left: #{@player.x * 16 -8 + @player.id * 2}px; top: #{@player.y * 16 -18 + @player.id * 3}px"}>
      <img src={"/images/p#{@player.id}_#{get_action_display(@player.current_action)}.gif"} height="32" width="32" />
    </div>
    """
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1000)
    new_game = Game.advance_round(socket.assigns.game)
    {:noreply, assign(socket, :game, new_game)}
  end

  def get_opacity(eaten) do
    if eaten, do: 0, else: 1
  end

  def get_action_display(action) do
    if action == "bite", do: "bite", else: "idle"
  end
end
