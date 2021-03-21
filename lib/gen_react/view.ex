defmodule GenReact.View do
  use GenServer
  import GenReact.Common
  require Logger

  def start_link(f, opts \\ []) do
    id = Keyword.get(opts, :id, nil) || new_id()
    {:ok, _} = GenServer.start_link(__MODULE__, {id, f, nil}, name: build_name(id))
    {:ok, id}
  end

  ## Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:get, t}, _, {id, f, value}) do
    {:reply, t.(value), {id, f, value}}
  end

  def handle_call(_, _, state) do
    {:reply, {:error, :unsupported_operation}, state}
  end

  def handle_cast({:subscription_update, _, upstream}, {id, f, old_value}) do
    new_value = f.(upstream)
    dispatch(id, old_value, new_value)
    {:noreply, {id, f, new_value}, :hibernate}
  end
end
