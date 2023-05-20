defmodule Forager.Worker do
  @default_timeout 1_000
  @default_reductions 1_000_000

  def run(fun, options \\ %{}) do
    pid = spawn_worker(fun)
    max_reductions = options[:max_reductions] || @default_reductions
    timeout = options[:timeout] || @default_timeout
    if max_reductions, do: wait_reductions(pid, max_reductions)
    receive_response(pid, timeout)
  end

  defp spawn_worker(fun) do
    parent = self()
    start_ms = :erlang.monotonic_time(:millisecond)

    :erlang.spawn_opt(
      fn ->
        try do
          result = fun.()
          {:reductions, reductions} = Process.info(self(), :reductions)

          reply = %{
            result: result,
            reductions: reductions,
            duration: :erlang.monotonic_time(:millisecond) - start_ms
          }

          send(parent, {self(), {:ok, reply}})
        catch
          :error, reason ->
            send(parent, {self(), {:error, reason}})
        end
      end,
      [:link]
    )
  end

  def wait_reductions(pid, max_reds) do
    case Process.info(pid, :reductions) do
      nil ->
        :ok

      {:reductions, reds} when reds >= max_reds ->
        Process.exit(pid, :kill)
        {:killed, reds}

      {:reductions, _} ->
        wait_reductions(pid, max_reds)
    end
  end

  defp receive_response(pid, timeout) do
    receive do
      {^pid, reply} ->
        reply

      {:error, error} ->
        {:error, error}
    after
      timeout ->
        Process.exit(pid, :kill)
        {:error, :timeout}
    end
  end

end
