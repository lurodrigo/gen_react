import GenReact

{:ok, root} = value(1)
{:ok, step_a} = view(fn x -> 3 * x end)
{:ok, step_b} = view(fn x -> x + 1 end)

subscribe(step_a, to: root)
subscribe(step_b, to: step_a)
