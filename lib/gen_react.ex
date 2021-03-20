defmodule GenReact do
  use Application

  def start do
    Supervisor.start_link(
      [GenReact.Registry],
      strategy: :one_for_one,
      name: __MODULE__
    )
  end
end
