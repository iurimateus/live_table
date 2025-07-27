# Table Options API Reference

Table options control the behavior and appearance of your LiveTable. They can be configured at three levels: built-in defaults, application-wide settings, and per-table overrides.

## Configuration Hierarchy

LiveTable uses a three-tier configuration system where each level overrides the previous:

1. **LiveTable Defaults** - Built-in sensible defaults
2. **Application Configuration** - Set in `config/config.exs`
3. **Table Options** - Per-table overrides via `table_options/0`

## Per-Table Configuration

Override settings for specific tables by implementing `table_options/0`:

```elixir
defmodule YourAppWeb.ProductLive.Index do
  use YourAppWeb, :live_view
  use LiveTable.LiveResource, schema: YourApp.Product

  def table_options do
    %{
      pagination: %{
        enabled: true,
        sizes: [10, 25, 50]
      },
      sorting: %{
        default_sort: [name: :asc]
      },
      mode: :table
    }
  end
end
```

## Application-Wide Configuration

Set defaults for all tables in your application:

```elixir
# config/config.exs
config :live_table,
  defaults: %{
    pagination: %{
      enabled: true,
      sizes: [20, 50, 100]
    },
    sorting: %{
      default_sort: [inserted_at: :desc]
    },
    exports: %{
      enabled: true,
      formats: [:csv, :pdf]
    }
  }
```

## Available Options

### Pagination Options

Control pagination behavior and appearance.

```elixir
pagination: %{
  enabled: true,              # Enable/disable pagination
  sizes: [10, 25, 50],       # Available page size options
  default_size: 25           # Default page size
}
```

**Options:**
- `enabled` (boolean) - Enable or disable pagination entirely
- `sizes` (list) - Available page size options (recommended max: 50)
- `default_size` (integer) - Default number of records per page

**Examples:**

```elixir
# Disable pagination (show all records)
pagination: %{enabled: false}

# Custom page sizes for admin interface
pagination: %{
  enabled: true,
  sizes: [5, 15, 30, 50],
  default_size: 15
}

# Large datasets with conservative pagination
pagination: %{
  enabled: true,
  sizes: [10, 20],
  default_size: 10
}
```

### Sorting Options

Configure sorting behavior and defaults.

```elixir
sorting: %{
  enabled: true,                     # Enable/disable sorting
  default_sort: [id: :asc]          # Default sort order
}
```

**Options:**
- `enabled` (boolean) - Enable or disable column sorting
- `default_sort` (keyword list) - Default sort columns and directions

**Examples:**

```elixir
# Default sort order
sorting: %{
  enabled: true,
  default_sort: [name: :asc]
}

# Disable sorting entirely
sorting: %{enabled: false}
```

### Export Options

Control export functionality and formats.

```elixir
exports: %{
  enabled: true,                    # Enable/disable exports
  formats: [:csv, :pdf]            # Available export formats
}
```

**Options:**
- `enabled` (boolean) - Enable or disable export functionality
- `formats` (list) - Available formats (`:csv`, `:pdf`, or both)

**Examples:**

```elixir
# CSV exports only
exports: %{
  enabled: true,
  formats: [:csv]
}

# PDF reports only
exports: %{
  enabled: true,
  formats: [:pdf]
}

# Disable exports for sensitive data
exports: %{enabled: false}
```

### Debug Options

Preview the query to debug. Works only in `Mix.env == :dev`

```elixir
debug: :off # Set to off by default
```

**Options:**
- `:off` - Disable debugging mode. Set to :off by default.
- `:query` - Preview the fully built query before fetching from database
- `:trace` - Trace the query as it gets built, useful for debugging

**Examples:**

```elixir
# Turn off debug
debug: :off

# Show the full compiled query
debug: :query

# Trace the query building
debug: :trace
```

### Search Options

Configure global search behavior.

```elixir
search: %{
  enabled: true,                    # Enable/disable search
  debounce: 300,                   # Debounce time in milliseconds
  placeholder: "Search records..."  # Search input placeholder
}
```

**Options:**
- `enabled` (boolean) - Enable or disable global text search
- `debounce` (integer) - Delay before search executes (milliseconds)
- `placeholder` (string) - Placeholder text for search input

**Examples:**

```elixir
# Quick search for small datasets
search: %{
  enabled: true,
  debounce: 100,
  placeholder: "Quick search..."
}

# Slower search for large datasets
search: %{
  enabled: true,
  debounce: 500,
  placeholder: "Search products..."
}

# Disable search
search: %{enabled: false}
```

### Display Mode Options

Control table layout and appearance.

```elixir
mode: :table  # or :card
```

**Table Mode:**
Traditional table layout with rows and columns.

```elixir
mode: :table
```

**Card Mode:**
Grid layout using custom card components.

```elixir
mode: :card,
card_component: &product_card/1
```

### Custom Components

Override default LiveTable components.

```elixir
components: %{
  header: &custom_header/1,         # Custom table header
  pagination: &custom_pagination/1,  # Custom pagination controls
  search: &custom_search/1          # Custom search input
}
```

## Complete Configuration Examples

### E-commerce Product Table

```elixir
def table_options do
  %{
    pagination: %{
      enabled: true,
      sizes: [12, 24, 48],
      default_size: 24
    },
    sorting: %{
      enabled: true,
      default_sort: [featured: :desc, name: :asc],
      multi_column: true
    },
    exports: %{
      enabled: true,
      formats: [:csv]
    },
    search: %{
      enabled: true,
      debounce: 300,
      placeholder: "Search products..."
    },
    mode: :card,
    card_component: &product_card/1,
    card_component: &product_card/1
  }
end

defp product_card(assigns) do
  ~H"""
  <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow">
    <img src={@record.image_url} alt={@record.name} class="w-full h-48 object-cover rounded mb-4" />
    <h3 class="font-semibold text-lg mb-2"><%= @record.name %></h3>
    <p class="text-gray-600 text-sm mb-4"><%= @record.description %></p>
    <div class="flex justify-between items-center">
      <span class="text-xl font-bold text-green-600">$<%= @record.price %></span>
      <span class="text-sm text-gray-500"><%= @record.stock_quantity %> in stock</span>
    </div>
  </div>
  """
end
```

### Admin User Management Table

```elixir
def table_options do
  %{
    pagination: %{
      enabled: true,
      sizes: [10, 25, 50, 100],
      default_size: 25
    },
    sorting: %{
      enabled: true,
      default_sort: [last_sign_in_at: :desc],
      multi_column: true
    },
    exports: %{
      enabled: true,
      formats: [:csv, :pdf]
    },
    search: %{
      enabled: true,
      debounce: 300,
      placeholder: "Search by name or email..."
    },
    mode: :table
  }
end
```

### Analytics Dashboard Table

```elixir
def table_options do
  %{
    pagination: %{
      enabled: true,
      sizes: [50, 100, 200],
      default_size: 100
    },
    sorting: %{
      enabled: true,
      default_sort: [date: :desc, revenue: :desc],
      multi_column: true
    },
    exports: %{
      enabled: true,
      formats: [:csv, :pdf]
    },
    search: %{
      enabled: false  # Disable search for analytics data
    },
    mode: :table
  }
end
```

### Development and Debugging Configuration

```elixir
def table_options do
  %{
    pagination: %{
      enabled: true,
      sizes: [5, 10, 15],     # Smaller pages for easier debugging
      default_size: 5
    },
    sorting: %{
      enabled: true,
      default_sort: [id: :asc]
    },
    exports: %{enabled: false}, # Disable exports during development
    search: %{
      enabled: true,
      debounce: 100           # Faster response for development
    },
    debug: :query             # Show final queries in terminal
  }
end
```

## Environment-Specific Configuration

Configure different settings per environment:

```elixir
# config/dev.exs
config :live_table,
  defaults: %{
    pagination: %{
      sizes: [5, 10, 15],    # Smaller pages for development
      default_size: 5
    },
    exports: %{enabled: false},  # Disable exports in development
    debug: :query                # Show queries in development
  }

# config/test.exs
config :live_table,
  defaults: %{
    pagination: %{enabled: false},  # Show all records in tests
    exports: %{enabled: false},
    search: %{debounce: 0}         # No debounce in tests
    # debug set to :off by default
  }

# config/prod.exs
config :live_table,
  defaults: %{
    pagination: %{
      sizes: [25, 50, 100],
      default_size: 50
    },
    exports: %{
      enabled: true,
      formats: [:csv, :pdf]
    },
    search: %{debounce: 500}       # Longer debounce for production
    # debug set to :off by default
  }
```

## Card Mode Configuration

### Basic Card Layout

```elixir
def table_options do
  %{
    mode: :card,
    card_component: &simple_card/1
  }
end

defp simple_card(assigns) do
  ~H"""
  <div class="p-4 border rounded-lg">
    <h3 class="font-semibold"><%= @record.name %></h3>
    <p class="text-gray-600"><%= @record.description %></p>
  </div>
  """
end
```

### Responsive Card Grid

```elixir
def table_options do
  %{
    mode: :card,
    card_component: &responsive_card/1
  }
end
```

### Advanced Card with Actions

```elixir
defp product_card(assigns) do
  ~H"""
  <div class="bg-white rounded-lg shadow border hover:shadow-md transition-shadow">
    <div class="aspect-w-16 aspect-h-9">
      <img src={@record.image_url} alt={@record.name} class="object-cover rounded-t-lg" />
    </div>

    <div class="p-4">
      <div class="flex justify-between items-start mb-2">
        <h3 class="font-semibold text-lg truncate"><%= @record.name %></h3>
        <span class={[
          "px-2 py-1 text-xs rounded-full",
          if(@record.active, do: "bg-green-100 text-green-800", else: "bg-red-100 text-red-800")
        ]}>
          <%= if @record.active, do: "Active", else: "Inactive" %>
        </span>
      </div>

      <p class="text-gray-600 text-sm mb-4 line-clamp-2"><%= @record.description %></p>

      <div class="flex justify-between items-center mb-4">
        <span class="text-xl font-bold text-green-600">$<%= @record.price %></span>
        <span class="text-sm text-gray-500"><%= @record.stock_quantity %> left</span>
      </div>

      <div class="flex gap-2">
        <.link
          navigate={~p"/products/#{@record.id}"}
          class="flex-1 bg-blue-600 text-white text-center py-2 px-4 rounded text-sm hover:bg-blue-700"
        >
          Edit
        </.link>
        <button
          phx-click="toggle_featured"
          phx-value-id={@record.id}
          class="px-4 py-2 border border-gray-300 rounded text-sm hover:bg-gray-50"
        >
          <%= if @record.featured, do: "Unfeature", else: "Feature" %>
        </button>
      </div>
    </div>
  </div>
  """
end
```

## Custom Header Components

Override the default table header:

```elixir
def table_options do
  %{
    components: %{
      header: &custom_header/1
    }
  }
end

defp custom_header(assigns) do
  ~H"""
  <div class="bg-gradient-to-r from-blue-600 to-blue-800 text-white p-4 rounded-t-lg">
    <div class="flex justify-between items-center">
      <h2 class="text-xl font-semibold">Product Inventory</h2>
      <div class="flex gap-2">
        <button class="bg-white bg-opacity-20 px-3 py-1 rounded text-sm">
          Bulk Actions
        </button>
        <button class="bg-white bg-opacity-20 px-3 py-1 rounded text-sm">
          Import
        </button>
      </div>
    </div>

    <div class="mt-2 text-blue-100 text-sm">
      Total Products: <%= @total_count %> |
      Active: <%= @active_count %> |
      Low Stock: <%= @low_stock_count %>
    </div>
  </div>
  """
end
```

## Performance Considerations

### Large Datasets

```elixir
def table_options do
  %{
    pagination: %{
      enabled: true,
      sizes: [25, 50]        # Smaller page sizes
    },
    search: %{
      debounce: 500          # Longer debounce
    }
  }
end
```

### Real-time Updates

```elixir
def table_options do
  %{
    pagination: %{
      enabled: true,
      sizes: [10, 20]        # Smaller pages for faster updates
    },
    search: %{
      debounce: 200          # Quicker search response
    }
  }
end
```

## Troubleshooting

### Common Issues

**Table not respecting options:**
- Ensure `table_options/0` is properly defined
- Check for syntax errors in the options map
- Verify configuration hierarchy (table options override app config)

**Card mode not working:**
- Confirm `card_component` function is defined
- Check that the component function accepts proper assigns
- Verify card grid configuration

**Pagination not showing:**
- Ensure `pagination.enabled` is `true`
- Check that you have more records than `default_size`
- Verify page size options are reasonable

**Exports not available:**
- Check `exports.enabled` is `true`
- Verify Oban configuration for background processing
- Ensure export formats are properly specified

**Debug not showing output:**
- Ensure you're running in `:dev` environment
- Check that `debug` is set to `:query` or `:trace` (not `:off`)
- Verify configuration hierarchy (table options override app config)
- Look for output in your terminal/console, not browser

### Debugging Configuration

```elixir
# Check effective configuration
def mount(_params, _session, socket) do
  effective_config = get_merged_table_options()
  IO.inspect(effective_config, label: "Table Config")
  {:ok, socket}
end

# Verify specific options
def table_options do
  config = %{
    pagination: %{enabled: true, sizes: [10, 25]},
    sorting: %{default_sort: [name: :asc]}
  }

  IO.inspect(config, label: "Table Options")
  config
end
```
