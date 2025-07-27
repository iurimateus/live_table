defmodule LiveTable.TableComponent do
  @moduledoc false
  defmacro __using__(opts) do
    quote do
      use Phoenix.Component
      import LiveTable.SortHelpers
      alias Phoenix.LiveView.JS

      def live_table(var!(assigns)) do
        var!(assigns) = assign(var!(assigns), :table_options, unquote(opts)[:table_options])

        ~H"""
        <div class="w-full" id="live-table" phx-hook="Download">
          <.render_header {assigns} />
          <.render_content {assigns} />
          <.render_footer {assigns} />
        </div>
        """
      end

      defp render_header(%{table_options: %{custom_header: {module, function}}} = assigns) do
        # Call custom header component
        apply(module, function, [assigns])
      end

      defp render_header(var!(assigns)) do
        ~H"""
        <.header_section
          fields={@fields}
          filters={@filters}
          options={@options}
          table_options={@table_options}
        />
        """
      end

      defp header_section(%{table_options: %{mode: :table}} = var!(assigns)) do
        ~H"""
        <div class="px-4 sm:px-6 lg:px-8">
          <!-- Header with title -->
          <div class="flex sm:items-center justify-end">
            <div
              :if={get_in(@table_options, [:exports, :enabled])}
              class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none"
            >
              <.exports formats={get_in(@table_options, [:exports, :formats])} />
            </div>
          </div>
          
        <!-- Controls section -->
          <div class="mt-4">
            <.common_controls
              fields={@fields}
              filters={@filters}
              options={@options}
              table_options={@table_options}
            />
          </div>
        </div>
        """
      end

      defp header_section(%{table_options: %{mode: :card}} = var!(assigns)) do
        ~H"""
        <div class="px-4 sm:px-6 lg:px-8">
          <div class="flex sm:items-center justify-end">
            <div
              :if={get_in(@table_options, [:exports, :enabled])}
              class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none"
            >
              <.exports formats={get_in(@table_options, [:exports, :formats])} />
            </div>
          </div>
          <div class="mt-4">
            <.common_controls
              fields={@fields}
              filters={@filters}
              options={@options}
              table_options={@table_options}
            />
          </div>
        </div>
        """
      end

      defp common_controls(var!(assigns)) do
        ~H"""
        <.form for={%{}} phx-debounce={get_in(@table_options, [:search, :debounce])} phx-change="sort">
          <div class="space-y-4">
            <!-- Search and controls bar -->
            <div class="flex flex-col sm:flex-row sm:items-center gap-2">
              <div class="flex items-center gap-3">
                <!-- Search -->
                <div
                  :if={
                    Enum.any?(@fields, fn
                      {_, %{searchable: true}} -> true
                      _ -> false
                    end) && @table_options.search.enabled
                  }
                  class="w-64"
                >
                  <label for="table-search" class="sr-only">Search</label>
                  <div class="relative rounded-md shadow-sm">
                    <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
                      <svg
                        class="h-5 w-5 text-gray-400"
                        viewBox="0 0 20 20"
                        fill="currentColor"
                        aria-hidden="true"
                      >
                        <path
                          fill-rule="evenodd"
                          d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z"
                          clip-rule="evenodd"
                        />
                      </svg>
                    </div>
                    <input
                      type="text"
                      name="search"
                      autocomplete="off"
                      id="table-search"
                      class="w-full rounded-md border-0 py-1.5 pl-10 text-gray-900 ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-white dark:ring-gray-700 dark:placeholder:text-gray-500 dark:focus:ring-indigo-500"
                      placeholder={@table_options[:search][:placeholder]}
                      value={@options["filters"]["search"]}
                    />
                  </div>
                </div>
                
        <!-- Per page -->
                <select
                  :if={@options["pagination"]["paginate?"]}
                  name="per_page"
                  value={@options["pagination"]["per_page"]}
                  class="w-20 rounded-md border-0 py-1.5 pl-3 pr-8 text-gray-900 ring-1 ring-inset ring-gray-300 focus:ring-2 focus:ring-indigo-600 sm:text-sm sm:leading-6 dark:bg-gray-800 dark:text-white dark:ring-gray-700 dark:focus:ring-indigo-500"
                >
                  {Phoenix.HTML.Form.options_for_select(
                    get_in(@table_options, [:pagination, :sizes]),
                    @options["pagination"]["per_page"]
                  )}
                </select>
              </div>
              
        <!-- Filter toggle -->
              <button
                :if={length(@filters) > 3}
                type="button"
                phx-click="toggle_filters"
                class="inline-flex items-center gap-x-1.5 rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 dark:bg-gray-800 dark:text-white dark:ring-gray-700 dark:hover:bg-gray-700"
              >
                <svg class="-ml-0.5 h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path
                    fill-rule="evenodd"
                    d="M2.628 1.601C5.028 1.206 7.49 1 10 1s4.973.206 7.372.601a.75.75 0 01.628.74v2.288a2.25 2.25 0 01-.659 1.59l-4.682 4.683a2.25 2.25 0 00-.659 1.59v3.037c0 .684-.31 1.33-.844 1.757l-1.937 1.55A.75.75 0 018 18.25v-5.757a2.25 2.25 0 00-.659-1.591L2.659 6.22A2.25 2.25 0 012 4.629V2.34a.75.75 0 01.628-.74z"
                    clip-rule="evenodd"
                  />
                </svg>
                <span phx-update="ignore" id="filter-toggle-text">Filters</span>
              </button>
            </div>
            
        <!-- Filters section -->
            <div
              id="filters-container"
              class={["", length(@filters) > 3 && "hidden"]}
              phx-hook="FilterToggle"
            >
              <.filters filters={@filters} applied_filters={@options["filters"]} />
            </div>
          </div>
        </.form>
        """
      end

      defp render_content(%{table_options: %{custom_content: {module, function}}} = assigns) do
        # Call custom content component
        apply(module, function, [assigns])
      end

      defp render_content(var!(assigns)) do
        ~H"""
        <.content_section {assigns} />
        """
      end

      defp content_section(%{table_options: %{mode: :table}} = var!(assigns)) do
        ~H"""
        <div class="mt-8 flow-root">
          <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
            <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
              <div class="overflow-hidden shadow sm:rounded-lg">
                <table class="min-w-full divide-y divide-gray-300 dark:divide-gray-700">
                  <thead class="bg-gray-50 dark:bg-gray-800">
                    <tr>
                      <th
                        :for={{key, field} <- @fields}
                        scope="col"
                        class="px-3 py-3.5 text-start text-sm font-semibold text-gray-900 dark:text-gray-100"
                      >
                        <.sort_link
                          key={key}
                          label={field.label}
                          sort_params={@options["sort"]["sort_params"]}
                          sortable={field.sortable}
                        />
                      </th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-gray-200 bg-white dark:divide-gray-700 dark:bg-gray-900">
                    <tr id="empty-placeholder" class="only:table-row hidden">
                      <td colspan={length(@fields)} class="py-10 text-center">
                        <svg
                          class="mx-auto h-12 w-12 text-gray-400"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke="currentColor"
                          aria-hidden="true"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M9 13h6m-3-3v6m-9 1V7a2 2 0 012-2h6l2 2h6a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z"
                          />
                        </svg>
                        <h3 class="mt-2 text-sm font-semibold text-gray-900 dark:text-gray-100">
                          No data
                        </h3>
                        <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
                          Get started by creating a new record.
                        </p>
                      </td>
                    </tr>
                    <.render_row streams={@streams} fields={@fields} table_options={@table_options} />
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
        """
      end

      defp content_section(%{table_options: %{mode: :card, use_streams: false}} = var!(assigns)) do
        ~H"""
        <div class="mt-8 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          <div :for={record <- @streams}>
            {@table_options.card_component.(%{record: record})}
          </div>
        </div>
        """
      end

      defp content_section(%{table_options: %{mode: :card, use_streams: true}} = var!(assigns)) do
        ~H"""
        <div class="mt-8 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          <div :for={{id, record} <- @streams.resources} id={id}>
            {@table_options.card_component.(%{record: record})}
          </div>
        </div>
        """
      end

      defp render_row(%{table_options: %{use_streams: false}} = var!(assigns)) do
        ~H"""
        <tr
          :for={resource <- @streams}
          class="hover:bg-gray-50 dark:hover:bg-gray-800 text-gray-800 dark:text-neutral-200"
        >
          <td
            :for={{key, field} <- @fields}
            class="whitespace-nowrap px-3 py-4 text-sm text-gray-900 dark:text-gray-100"
          >
            {render_cell(Map.get(resource, key), field, resource)}
          </td>
        </tr>
        """
      end

      defp render_row(%{table_options: %{use_streams: true}} = var!(assigns)) do
        ~H"""
        <tr
          :for={{id, resource} <- @streams.resources}
          id={id}
          class="hover:bg-gray-50 dark:hover:bg-gray-800 text-gray-800 dark:text-neutral-200"
        >
          <td
            :for={{key, field} <- @fields}
            class="whitespace-nowrap px-3 py-4 text-sm text-gray-900 dark:text-gray-100"
          >
            {render_cell(Map.get(resource, key), field, resource)}
          </td>
        </tr>
        """
      end

      defp render_row(_),
        do:
          raise(ArgumentError,
            message: "Requires `use_streams` to be set to a boolean in table_options"
          )

      defp footer_section(var!(assigns)) do
        ~H"""
        <.paginate
          :if={@options["pagination"]["paginate?"]}
          current_page={@options["pagination"]["page"]}
          has_next_page={@options["pagination"][:has_next_page]}
        />
        """
      end

      defp render_footer(%{table_options: %{custom_footer: {module, function}}} = assigns) do
        # Call custom content component
        apply(module, function, [assigns])
      end

      defp render_footer(var!(assigns)) do
        ~H"""
        <.footer_section {assigns} />
        """
      end

      def filters(var!(assigns)) do
        ~H"""
        <div :if={@filters != []} class="rounded-lg bg-gray-50 p-4 dark:bg-gray-800">
          <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <%= for {key, filter} <- @filters do %>
              <div>
                {filter.__struct__.render(%{
                  key: key,
                  filter: filter,
                  applied_filters: @applied_filters
                })}
              </div>
            <% end %>
          </div>
          <div
            :if={@applied_filters != %{"search" => ""}}
            class="mt-4 flex justify-end border-t border-gray-200 pt-4 dark:border-gray-700"
          >
            <.link
              phx-click="sort"
              phx-value-clear_filters="true"
              class="inline-flex items-center gap-x-1.5 rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 dark:bg-gray-800 dark:text-white dark:ring-gray-700 dark:hover:bg-gray-700"
            >
              <svg class="-ml-0.5 h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                <path
                  fill-rule="evenodd"
                  d="M8.75 1A2.75 2.75 0 006 3.75v.443c-.795.077-1.584.176-2.365.298a.75.75 0 10.23 1.482l.149-.022.841 10.518A2.75 2.75 0 007.596 19h4.807a2.75 2.75 0 002.742-2.53l.841-10.52.149.023a.75.75 0 00.23-1.482A41.03 41.03 0 0014 4.193V3.75A2.75 2.75 0 0011.25 1h-2.5zM10 4c.84 0 1.673.025 2.5.075V3.75c0-.69-.56-1.25-1.25-1.25h-2.5c-.69 0-1.25.56-1.25 1.25v.325C8.327 4.025 9.16 4 10 4zM8.58 7.72a.75.75 0 00-1.5.06l.3 7.5a.75.75 0 101.5-.06l-.3-7.5zm4.34.06a.75.75 0 10-1.5-.06l-.3 7.5a.75.75 0 101.5.06l.3-7.5z"
                  clip-rule="evenodd"
                />
              </svg>
              Clear filters
            </.link>
          </div>
        </div>
        """
      end

      def paginate(var!(assigns)) do
        ~H"""
        <nav class="flex items-center justify-between px-4 py-3 sm:px-6" aria-label="Pagination">
          <div class="hidden sm:block">
            <p class="text-sm text-gray-700 dark:text-gray-300">
              Page <span class="font-medium">{@current_page}</span>
            </p>
          </div>
          <div class="flex flex-1 justify-between sm:justify-end">
            <.link
              phx-click="sort"
              phx-value-page={String.to_integer(@current_page) - 1}
              class={[
                "relative inline-flex items-center rounded-md px-3 py-2 text-sm font-semibold ring-1 ring-inset",
                if String.to_integer(@current_page) == 1 do
                  "bg-gray-100 text-gray-400 ring-gray-300 cursor-not-allowed dark:bg-gray-800 dark:text-gray-600 dark:ring-gray-700"
                else
                  "bg-white text-gray-900 ring-gray-300 hover:bg-gray-50 dark:bg-gray-800 dark:text-white dark:ring-gray-700 dark:hover:bg-gray-700"
                end
              ]}
              aria-disabled={String.to_integer(@current_page) == 1}
            >
              Previous
            </.link>
            <.link
              phx-click="sort"
              phx-value-page={String.to_integer(@current_page) + 1}
              class={[
                "relative ml-3 inline-flex items-center rounded-md px-3 py-2 text-sm font-semibold ring-1 ring-inset",
                if !@has_next_page do
                  "bg-gray-100 text-gray-400 ring-gray-300 cursor-not-allowed dark:bg-gray-800 dark:text-gray-600 dark:ring-gray-700"
                else
                  "bg-white text-gray-900 ring-gray-300 hover:bg-gray-50 dark:bg-gray-800 dark:text-white dark:ring-gray-700 dark:hover:bg-gray-700"
                end
              ]}
              aria-disabled={!@has_next_page}
            >
              Next
            </.link>
          </div>
        </nav>
        """
      end

      def exports(var!(assigns)) do
        ~H"""
        <div class="relative inline-block text-left">
          <div>
            <button
              type="button"
              class="inline-flex cursor-pointer w-full justify-center gap-x-1.5 rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 dark:bg-gray-800 dark:text-white dark:ring-gray-700 dark:hover:bg-gray-700"
              id="export-menu-button"
              aria-expanded="false"
              aria-haspopup="true"
              phx-click={
                JS.toggle(
                  to: "#export-dropdown",
                  in: "transition ease-out duration-100 transform opacity-0 scale-95",
                  out: "transition ease-in duration-75 transform opacity-100 scale-100"
                )
              }
            >
              Export
              <svg
                class="-mr-1 h-5 w-5 text-gray-400"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z"
                  clip-rule="evenodd"
                />
              </svg>
            </button>
          </div>

          <div
            id="export-dropdown"
            class="absolute right-0 z-10 mt-2 w-56 origin-top-right rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none dark:bg-gray-800 dark:ring-gray-700 hidden"
            role="menu"
            aria-orientation="vertical"
            aria-labelledby="export-menu-button"
            tabindex="-1"
          >
            <div class="py-1" role="none">
              <.link
                :for={format <- @formats}
                href="#"
                phx-click={if format == :csv, do: "export-csv", else: "export-pdf"}
                class="text-gray-700 dark:text-gray-300 block px-4 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700"
                role="menuitem"
                tabindex="-1"
              >
                Export as {String.upcase(to_string(format))}
              </.link>
            </div>
          </div>
        </div>
        """
      end

      defp render_cell(value, field, _record)
           when is_nil(value) and not is_nil(field.empty_text) do
        field.empty_text
      end

      defp render_cell(value, %{renderer: renderer}, record) when is_function(renderer, 1) do
        renderer.(value)
      end

      defp render_cell(value, %{renderer: renderer}, record) when is_function(renderer, 2) do
        renderer.(value, record)
      end

      defp render_cell(value, %{component: component}, record) when is_function(component, 1) do
        component.(%{value: value, record: record})
      end

      defp render_cell(value, %{component: component}, record) when is_function(component, 2) do
        component.(value, record)
      end

      defp render_cell(true, _field, _record), do: "Yes"
      defp render_cell(false, _field, _record), do: "No"
      defp render_cell(value, _field, _record), do: Phoenix.HTML.Safe.to_iodata(value)

      defoverridable live_table: 1,
                     render_header: 1,
                     render_content: 1,
                     render_footer: 1
    end
  end
end
