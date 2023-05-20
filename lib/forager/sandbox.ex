defmodule Forager.Sandbox do
  alias Forager.Worker

  @luerl_global :_G
  @sandboxed_value :sandboxed

  @sandboxed_globals [
    [@luerl_global, :io],
    [@luerl_global, :file],
    [@luerl_global, :os, :execute],
    [@luerl_global, :os, :exit],
    [@luerl_global, :os, :getenv],
    [@luerl_global, :os, :remove],
    [@luerl_global, :os, :rename],
    [@luerl_global, :os, :tmpname],
    [@luerl_global, :package],
    [@luerl_global, :load],
    [@luerl_global, :loadfile],
    [@luerl_global, :require],
    [@luerl_global, :dofile],
    [@luerl_global, :load],
    [@luerl_global, :loadfile],
    [@luerl_global, :loadstring]
  ]

  def init(), do: init(:luerl.init())

  def eval_function(state, path, args, options \\ %{})
      when is_list(path) and is_list(args) and is_map(options) do
    fun = fn ->
      {result, _state} = :luerl.call_function(path, args, state)
      result
    end

    Worker.run(fun, options)
  end

  def run(state, lua_code, options \\ %{}) when is_map(options) do
    fun = fn -> :luerl.do(lua_code, state) end
    Worker.run(fun, options)
  end

  def add_script(state, lua_code, options \\ %{}) when is_map(options) do
    fun = fn ->
      {_, new_state} = :luerl.do(lua_code, state)
      new_state
    end

    {:ok, %{result: result}} = Worker.run(fun, options)
    result
  end

  def add_function(state, name, fun) do
    lua_fun = fn args, state -> {[fun.(args)], state} end
    :luerl.set_table([name], lua_fun, state)
  end

  defp init(table_paths) when is_list(table_paths) do
    init(:luerl.init(), table_paths)
  end

  defp init(state), do: init(state, @sandboxed_globals)

  defp init(state, []), do: :luerl.gc(state)

  defp init(state, [path | rest]) do
    path
    |> :luerl.set_table(@sandboxed_value, state)
    |> init(rest)
  end
end
