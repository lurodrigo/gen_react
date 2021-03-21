defmodule GenReact.Common do
  require Logger

  @subscription_tb :gen_react_subscriptions

  def dispatch_single(id, subscriber, value) do
    GenServer.cast(build_name(subscriber), {:subscription_update, id, value})
  end

  def dispatch(id, old_value, new_value) do
    subscriptions = :ets.lookup(@subscription_tb, id)

    if subscriptions != [] and old_value != new_value do
      Logger.debug("#{id}: sending #{inspect(new_value)}")

      for {_, subscriber} <- subscriptions do
        dispatch_single(id, subscriber, new_value)
      end
    end
  end

  def subscribe(subscriber, [{:to, id} | _opts]) do
    Logger.debug("Subscribing #{subscriber} to #{id}")
    send_value(id, subscriber)
    :ets.insert(@subscription_tb, {id, subscriber})
  end

  def unsubscribe(subscriber, to: id) do
    Logger.debug("Unsubscribe #{subscriber} to #{id}")
    :ets.delete_object(@subscription_tb, {id, subscriber})
  end

  defp send_value(from, to) do
    GenServer.cast(build_name(from), {:send_value, to})
  end

  def new_id(), do: UUID.uuid4()

  def build_name(id), do: {:via, Registry, {GenReact.Registry, id}}
end
