defmodule GenReactTest do
  use ExUnit.Case
  doctest GenReact

  test "greets the world" do
    assert GenReact.hello() == :world
  end
end
