defmodule Forager.Fruit do
  alias Forager.Fruit

  @fruit_types 5
  @values_by_type %{1 => 100, 2 => 200, 3 => 300, 4 => 500, 5 => 1_000}

  defstruct x: 0, y: 0, type: 0, value: 0, biters: nil, eaten: false

  def new(x, y) do
    type = get_random_fruit_type()
    value = @values_by_type[type]
    %Fruit{x: x, y: y, type: type, value: value}
  end

  def eaten?(fruit) do
    fruit.eaten
  end

  def to_view(fruit) when is_list(fruit) do
    fruit
    |> Enum.reject(&eaten?/1)
    |> Enum.map(&to_view/1)
  end

  def to_view(fruit) do
    Map.take(fruit, [:x, :y, :type, :value])
  end

  def reset(fruit) do
    %Fruit{fruit | biters: nil, eaten: false}
  end

  defp get_random_fruit_type() do
    ceil(:rand.uniform() * :rand.uniform() * @fruit_types)
  end
end
