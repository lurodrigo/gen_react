# GenReact

Data-flow like reactive programming in Elixir.

## Examples

```elixir 
import GenReact
{:ok, a} = value(1)
{:ok, b} = value(2)
{:ok, c} = view([a: a, b: b], fn %{a: a, b: b} -> 10*a + b end)
{:ok, d} = view(c, fn c -> c + 1 end)

{get(c), get(d)} # {12, 13}
set(a, 5)
set(b, 3)
{get(c), get(d)} # {53, 54}
```