defmodule Forager.Scripts do
  paths = Path.join([:code.priv_dir(:forager), "lua", "*.lua"]) |> Path.wildcard()
  @paths_hash :erlang.md5(paths)

  scripts_by_name =
    for path <- paths do
      @external_resource path
      script = File.read!(path)
      name = Path.basename(path)
      {name, script}
    end
    |> Map.new()

  @scripts_by_name scripts_by_name

  def get(name), do: @scripts_by_name[name]

  def __mix_recompile__?() do
    paths_hash =
      [:code.priv_dir(:forager), "lua", "*.lua"]
      |> Path.join()
      |> Path.wildcard()
      |> :erlang.md5()

    paths_hash != @paths_hash
  end
end
