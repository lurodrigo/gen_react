defmodule Broadcaster do
  use GenStage

  @doc "Starts the broadcaster."
  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc "Sends an event and returns only after the event is dispatched."
  def sync_notify(event, timeout \\ 5000) do
    GenStage.call(__MODULE__, {:notify, event}, timeout)
  end

  def init(:ok) do
    {:producer, :ok, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:notify, event}, _from, state) do
    # Dispatch immediately
    {:reply, :ok, [event], state}
  end

  def handle_demand(_demand, state) do
    # We don't care about the demand
    {:noreply, [], state}
  end
end
