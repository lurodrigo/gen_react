defmodule GenReact do
  use Application
  alias GenReact.{Value, View}

  def start(_type, _args) do
    children = []
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def subscribe(subscriber, to: pid) do
    GenServer.cast(pid, {:subscribe, subscriber})
  end

  def unsubscribe(subscriber, to: pid) do
    GenServer.cast(pid, {:unsubscribe, subscriber})
  end

  def value(initial_value) do
    Value.start_link(initial_value)
  end

  def view(f) do
    View.start_link(f)
  end

  def get(pid, f \\ & &1, timeout \\ 5000) do
    GenServer.call(pid, {:get, f}, timeout)
  end

  def get_and_update(pid, f, timeout \\ 5000) do
    GenServer.call(pid, {:get_and_update, f}, timeout)
  end

  def update(pid, f) do
    GenServer.cast(pid, {:update, f})
  end

  def sync_update(pid, f, timeout \\ 5000) do
    GenServer.call(pid, {:update, f}, timeout)
  end

  def set(pid, value) do
    GenServer.cast(pid, {:update, fn _ -> value end})
  end

  def sync_set(pid, value, timeout \\ 5000) do
    GenServer.call(pid, {:update, fn _ -> value end}, timeout)
  end
end
