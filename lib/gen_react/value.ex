defmodule GenReact.Value do
  use GenServer
  import GenReact.Common
  require Logger

  def start_link(initial_value, opts \\ []) do
    id = Keyword.get(opts, :id, nil) || new_id()
    {:ok, _} = GenServer.start_link(__MODULE__, {id, initial_value}, name: build_name(id))
    {:ok, id}
  end

  ## Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:get, t}, _, {id, value}) do
    {:reply, t.(value), {id, value}}
  end

  def handle_call({:get_and_update, f}, _, {id, value}) do
    {get, new_value} = f.(value)

    dispatch(id, value, new_value)
    {:reply, get, {id, new_value}}
  end

  def handle_call({:update, f}, _, {id, value}) do
    new_value = f.(value)

    dispatch(id, value, new_value)
    {:reply, new_value, {id, new_value}, :hibernate}
  end

  def handle_call(_, _, state) do
    {:reply, {:error, :unsupported_operation}, state}
  end

  def handle_cast({:update, f}, {id, value}) do
    new_value = f.(value)

    dispatch(id, value, new_value)
    {:noreply, {id, new_value}, :hibernate}
  end
end
