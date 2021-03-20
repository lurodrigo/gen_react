{:ok, value} = Value.start_link(1)
{:ok, view} = View.start_link(fn x -> 2 * x end)

GenStage.sync_subscribe(view, to: value, max_demand: 1)
