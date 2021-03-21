defmodule GenReact.View do
  use GenServer
  import GenReact.Common
  require Logger

  def start_link({f, ups, opts}) do
    id = Keyword.get(opts, :id, nil) || new_id()
    up_aliases = build_aliases(ups)

    {:ok, _} =
      GenServer.start_link(
        __MODULE__,
        %{id: id, f: f, up_aliases: up_aliases, up_values: %{}},
        name: build_name(id)
      )

    for {up_id, _} <- up_aliases, do: subscribe(id, to: up_id)

    {:ok, id}
  end

  ## Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:get, t}, _, %{value: value} = state) do
    {:reply, t.(value), state}
  end

  def handle_call({:get, _}, _, state) do
    {:reply, {:error, :no_value}, state}
  end

  def handle_call(_, _, state) do
    {:reply, {:error, :unsupported_operation}, state}
  end

  def handle_cast({:send_value, to}, %{id: id, value: value} = state) do
    GenServer.cast(build_name(to), {:subscription_update, id, value})
    {:noreply, state}
  end

  def handle_cast(
        {:subscription_update, from, from_value},
        %{value: _} = state
      ) do
    {:noreply, update_value({from, from_value}, state), :hibernate}
  end

  def handle_cast(
        {:subscription_update, from, from_value},
        %{up_aliases: up_aliases, up_values: up_values} = state
      ) do
    new_up_values = Map.put(up_values, Map.get(up_aliases, from), from_value)

    case map_size(new_up_values) == map_size(up_aliases) do
      true ->
        {:noreply, update_value({from, from_value}, state), :hibernate}

      false ->
        {:noreply, %{state | up_values: new_up_values}, :hibernate}
    end
  end

  defp update_value(
         {from, from_value},
         %{f: f, up_aliases: up_aliases, up_values: up_values, id: id} = state
       ) do
    new_up_values = Map.put(up_values, Map.get(up_aliases, from), from_value)
    new_value = f.(new_up_values)
    dispatch(id, Map.get(state, :value) || {new_value}, new_value)
    Map.merge(state, %{up_values: new_up_values, value: new_value})
  end

  defp build_aliases(ups) do
    ups
    |> Enum.map(fn
      {up_alias, id} -> {id, up_alias}
      id -> {id, id}
    end)
    |> Enum.into(%{})
  end
end
