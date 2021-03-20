defmodule Value do
  use GenStage
  require Logger

  @doc "Starts the broadcaster."
  def start_link(initial_value) do
    GenStage.start_link(__MODULE__, initial_value)
  end

  @doc "Sends an event and returns only after the event is dispatched."
  def get(pid, f \\ & &1, timeout \\ 5000) do
    GenStage.call(pid, {:get, f}, timeout)
  end

  def get_and_update(pid, f, timeout \\ 5000) do
    GenStage.call(pid, {:get_and_update, f}, timeout)
  end

  def update(pid, f \\ & &1, timeout \\ 5000) do
    GenStage.call(pid, {:update, f}, timeout)
  end

  def set(pid, value, timeout \\ 5000) do
    GenStage.call(pid, {:set, value}, timeout)
  end

  ## Callbacks

  def init(initial_value) do
    {:producer, {MapSet.new(), initial_value}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:get, f}, _, {subs, value}) do
    {:reply, f.(value), [], {subs, value}}
  end

  def handle_call({:get_and_update, f}, _, {subs, value}) do
    {get, new_value} = f.(value)

    if Enum.empty?(subs) do
      {:reply, get, [], {subs, new_value}}
    else
      Logger.info("#{inspect(self())}: sending new_value #{new_value}")
      {:reply, get, [{new_value}], {subs, new_value}}
    end
  end

  def handle_call({:update, f}, _, {subs, value}) do
    new_value = f.(value)

    if Enum.empty?(subs) do
      {:reply, :ok, [], {subs, new_value}}
    else
      Logger.info("#{inspect(self())}: sending new_value #{new_value}")
      {:reply, :ok, [{new_value}], {subs, new_value}}
    end
  end

  def handle_call({:set, new_value}, _, {subs, _}) do
    if Enum.empty?(subs) do
      {:reply, :ok, [], {subs, new_value}}
    else
      Logger.info("#{inspect(self())}: sending new_value #{new_value}")
      {:reply, :ok, [{new_value}], {subs, new_value}}
    end
  end

  def handle_cast({:send, pid}, {subs, value}) do
    :timer.sleep(3000)
    Logger.info("#{inspect(self())}: Sending to #{inspect(pid)} initial value #{value}")
    {:noreply, [{pid, value}], {subs, value}}
  end

  def handle_demand(demand, state) do
    Logger.info("#{inspect(self())}: Being demanded #{demand}")
    {:noreply, [state], state}
  end

  def handle_subscribe(:consumer, _opts, {pid, _}, {subs, value}) do
    Logger.info("#{inspect(self())}: #{inspect(pid)} has subscribed.")
    GenServer.cast(self(), {:send, pid})
    {:automatic, {MapSet.put(subs, pid), value}}
  end

  def handle_cancel(_, {pid, _}, {subs, value}) do
    {:noreply, [], {MapSet.delete(subs, pid), value}}
  end
end
