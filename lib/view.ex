defmodule View do
  use GenStage
  require Logger

  @doc "Starts the broadcaster."
  def start_link(f) do
    GenStage.start_link(__MODULE__, f)
  end

  @doc "Sends an event and returns only after the event is dispatched."
  def get(pid, f \\ & &1, timeout \\ 5000) do
    GenStage.call(pid, {:get, f}, timeout)
  end

  ## Callbacks

  def init(f) do
    {:producer_consumer, {MapSet.new(), f, nil}}
  end

  def handle_call({:get, transf}, _, {subs, f, value}) do
    {:reply, transf.(value), [], {subs, f, value}}
  end

  def handle_cast({:send, pid}, {subs, f, value}) do
    {:noreply, [{pid, value}], {subs, f, value}}
  end

  def handle_events([event | _], _from, {subs, f, old_value}) do
    Logger.info("Oi")

    new_value =
      case event do
        {upstream} -> f.(upstream)
        {_, upstream} -> f.(upstream)
      end

    Logger.info("#{inspect(self())}: updating #{inspect(old_value)} -> #{inspect(new_value)}")

    if Enum.empty?(subs) do
      {:noreply, [], {subs, f, new_value}}
    else
      {:noreply, [{new_value}], {subs, f, new_value}}
    end
  end

  def handle_events(events, _, state) do
    Logger.info("entrou no errado. Events: #{inspect(events)}")
    {:noreply, [], state}
  end

  def handle_subscribe(:consumer, _opts, {pid, _}, {subs, f, value}) do
    Logger.info("#{inspect(self())}: #{inspect(pid)} has subscribed.")
    GenServer.cast(self(), {:send, pid})
    {:automatic, {MapSet.put(subs, pid), f, value}}
  end

  def handle_subscribe(:producer, _opts, {pid, _}, state) do
    Logger.info("#{inspect(self())}: #{inspect(pid)} has accepted subscription.")
    {:automatic, state}
  end

  def handle_cancel(_, {pid, _}, {subs, f, value}) do
    Logger.info("#{inspect(self())}: #{inspect(pid)} has unsubscribed.")
    {:noreply, [], {MapSet.delete(subs, pid), f, value}}
  end
end
