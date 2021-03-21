defmodule GenReact do
  use Application
  import GenReact.Common
  alias GenReact.{Value, View}

  @subscription_tb :gen_react_subscriptions

  def start(_type, _args) do
    children = [{Registry, keys: :unique, name: GenReact.Registry}]
    :ets.new(@subscription_tb, [:named_table, :bag, :public])
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def stop(_) do
    :ets.delete(@subscription_tb)
  end

  def subscribe(subscriber, [{:to, id} | _opts]) do
    :ets.insert(@subscription_tb, {id, subscriber})
  end

  def unsubscribe(subscriber, to: id) do
    :ets.delete_object(@subscription_tb, {id, subscriber})
  end

  def value(initial_value, opts \\ []) do
    Value.start_link(initial_value, opts)
  end

  def view(f, opts \\ []) do
    View.start_link(f, opts)
  end

  def get(id, f \\ & &1, timeout \\ 5000) do
    GenServer.call(build_name(id), {:get, f}, timeout)
  end

  def get_and_update(id, f, timeout \\ 5000) do
    GenServer.call(build_name(id), {:get_and_update, f}, timeout)
  end

  def update(id, f) do
    GenServer.cast(build_name(id), {:update, f})
  end

  def sync_update(id, f, timeout \\ 5000) do
    GenServer.call(build_name(id), {:update, f}, timeout)
  end

  def set(id, value) do
    GenServer.cast(build_name(id), {:update, fn _ -> value end})
  end

  def sync_set(id, value, timeout \\ 5000) do
    GenServer.call(build_name(id), {:update, fn _ -> value end}, timeout)
  end
end
