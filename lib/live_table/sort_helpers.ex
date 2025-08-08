defmodule LiveTable.SortHelpers do
  @moduledoc false
  use Phoenix.Component

  # Renders a sortable column header with sort direction indicator
  def sort_link(%{sortable: true} = assigns) do
    ~H"""
    <div
      :if={@sortable}
      class="group inline-flex cursor-pointer whitespace-nowrap"
      phx-click="sort"
      id={@key}
      phx-hook="SortableColumn"
      phx-value-sort={
        Jason.encode!(%{
          @key => Map.get(@sort_params, @key, :asc) |> to_string() |> next_sort_order()
        })
      }
    >
      {@label}
      <span class="ml-2 flex-none rounded text-gray-400 group-hover:visible group-focus:visible">
        <svg
          class="size-3.5 ms-1 -me-0.5 text-gray-400 dark:text-neutral-500"
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <path
            class={[Map.get(@sort_params, @key) == :desc && "text-blue-600 dark:text-blue-500"]}
            d="m7 15 5 5 5-5"
          >
          </path>
          <path
            class={[Map.get(@sort_params, @key) == :asc && "text-blue-600 dark:text-blue-500"]}
            d="m7 9 5-5 5 5"
          >
          </path>
        </svg>
      </span>
    </div>
    """
  end

  # Renders a non-sortable column header
  def sort_link(assigns) do
    ~H"""
    <span>{@label}</span>
    """
  end

  # Toggles sort order between ascending and descending
  def next_sort_order("asc"), do: "desc"
  def next_sort_order("desc"), do: "asc"

  # Updates sort parameters in the state map when params are nil
  def update_sort_params(map, nil, _), do: map

  # Merges new sort params with existing ones when shift key is pressed
  def update_sort_params(map, params, true) do
    p =
      params
      |> Jason.decode!()
      |> Map.new(fn {k, v} -> {k, String.to_existing_atom(v)} end)

    Map.update(map, "sort_params", nil, &Map.merge(&1, p))
  end

  # Replaces existing sort params with new ones when shift key is not pressed
  def update_sort_params(map, params, false) do
    p =
      params
      |> Jason.decode!()
      |> Map.new(fn {k, v} -> {k, String.to_existing_atom(v)} end)

    Map.put(map, "sort_params", p)
  end

  # Dynamically calls a component function from a specified module. Used if user specifies a custom module.
  def dynamic_component(assigns) do
    {module, assigns} = Map.pop(assigns, :module)
    {function, assigns} = Map.pop(assigns, :function)
    apply(module, function, [assigns])
  end
end
