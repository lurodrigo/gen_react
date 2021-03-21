defmodule GenReact.Common do
  require Logger

  def dispatch_single(pid, value) do
    GenServer.cast(pid, {:subscription_update, self(), value})
  end

  def dispatch(subs, old_value, new_value) do
    if not Enum.empty?(subs) and old_value != new_value do
      Logger.debug("#{inspect(self())}: sending new_value #{new_value}")

      for sub <- subs do
        dispatch_single(sub, new_value)
      end
    end
  end
end
