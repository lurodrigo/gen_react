defmodule GenReact.View do
  use GenServer
  import GenReact.Common
  require Logger

  def start_link(f) do
    GenServer.start_link(__MODULE__, f)
  end

  ## Callbacks

  def init(f) do
    {:ok, {MapSet.new(), f, nil}}
  end

  def handle_call({:get, t}, _, {subs, f, value}) do
    {:reply, t.(value), {subs, f, value}}
  end

  def handle_call(_, _, state) do
    {:reply, {:error, :unsupported_operation}, state}
  end

  def handle_cast({:subscription_update, _, upstream}, {subs, f, old_value}) do
    new_value = f.(upstream)
    dispatch(subs, old_value, new_value)
    {:noreply, {subs, f, new_value}}
  end

  def handle_cast({:subscribe, pid}, {subs, f, value}) do
    Logger.debug("#{inspect(self())}: #{inspect(pid)} has subscribed.")
    dispatch_single(pid, value)
    {:noreply, {MapSet.put(subs, pid), f, value}}
  end

  def handle_cast({:unsubscribe, pid}, {subs, f, value}) do
    Logger.debug("#{inspect(self())}: #{inspect(pid)} has unsubscribed.")
    {:noreply, {MapSet.delete(subs, pid), f, value}}
  end
end
