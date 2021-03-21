import GenReact

{:ok, _} = value(1, id: :a)
{:ok, _} = value(2, id: :b)
{:ok, _} = view([:a, :b], fn %{a: a, b: b} -> 10*a + b end, id: :c)
{:ok, _} = view(:c, fn c -> c + 1 end, id: :d)

import GenReact
{:ok, a} = value(1)
{:ok, b} = value(2)
{:ok, c} = view([a: a, b: b], fn %{a: a, b: b} -> 10*a + b end)
{:ok, d} = view(c, fn c -> c + 1 end)

{get(c), get(d)} # {12, 13}
set(a, 5)
set(b, 3)
{get(c), get(d)} # {53, 54}

# a <~ 1
# b <~ 2
# c <~ 10*a + b
# d <~ c + 1
