defmodule GenReact.Value do
  use GenServer
  import GenReact.Common
  require Logger

  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value)
  end

  ## Callbacks

  def init(initial_value) do
    {:ok, {MapSet.new(), initial_value}}
  end

  def handle_call({:get, f}, _, {subs, value}) do
    {:reply, f.(value), {subs, value}}
  end

  def handle_call({:get_and_update, f}, _, {subs, value}) do
    {get, new_value} = f.(value)

    dispatch(subs, value, new_value)
    {:reply, get, {subs, new_value}}
  end

  def handle_call({:update, f}, _, {subs, value}) do
    new_value = f.(value)

    dispatch(subs, value, new_value)
    {:reply, new_value, {subs, new_value}}
  end

  def handle_call(_, _, state) do
    {:reply, {:error, :unsupported_operation}, state}
  end

  def handle_cast({:update, f}, {subs, value}) do
    new_value = f.(value)

    dispatch(subs, value, new_value)
    {:noreply, {subs, new_value}}
  end

  def handle_cast({:subscribe, pid}, {subs, value}) do
    Logger.debug("#{inspect(self())}: #{inspect(pid)} has subscribed.")
    dispatch_single(pid, value)
    {:noreply, {MapSet.put(subs, pid), value}}
  end

  def handle_cast({:unsubscribe, pid}, {subs, value}) do
    Logger.debug("#{inspect(self())}: #{inspect(pid)} has unsubscribed.")
    {:noreply, {MapSet.delete(subs, pid), value}}
  end
end
