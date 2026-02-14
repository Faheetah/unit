# Unit

A library for working with measurements in Elixir, supporting unit conversion and arithmetic operations.

## Features

- Support for multiple measurement types (volume, weight)
- Unit conversion between different units of the same type
- Arithmetic operations (addition, subtraction) between units of the same type
- Error handling for incompatible unit operations

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `unit` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:unit, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/unit>.

## Usage

### Creating Units

To create a unit, instantiate the appropriate struct with a value:

```elixir
# Create a weight measurement
weight = %Unit.Gram{value: 1000}

# Create a volume measurement
volume = %Unit.Cup{value: 2.5}
```

### Adding Units

Add units of the same type together:

```elixir
# Add two weight units (metric)
result = Unit.add(%Unit.Gram{value: 1000}, %Unit.Kilogram{value: 1})
# Returns: %Unit.Gram{value: 2000.0, ...}

# Add two weight units (imperial)
result = Unit.add(%Unit.Ounce{value: 16}, %Unit.Pound{value: 1})
# Returns: %Unit.Ounce{value: 32.0, ...}

# Add mixed weight units (metric and imperial)
result = Unit.add(%Unit.Gram{value: 1000}, %Unit.Pound{value: 1})
# Returns: %Unit.Gram{value: 1453.5924, ...}

# Add two volume units
result = Unit.add(%Unit.Cup{value: 1}, %Unit.Tablespoon{value: 16})
# Returns: %Unit.Cup{value: 2.0, ...}

# Add mixed volume units
result = Unit.add(%Unit.Milliliter{value: 1000}, %Unit.Cup{value: 1})
# Returns: %Unit.Milliliter{value: 1236.5882, ...}
```

Attempting to add units of different types will return an error:

```elixir
result = Unit.add(%Unit.Gram{value: 1000}, %Unit.Cup{value: 1})
# Returns: {:error, "Cannot add units of different types: Elixir.Unit.Weight and Elixir.Unit.Volume"}
```

### Converting Units

Convert a unit to another unit of the same type:

```elixir
# Convert weight units
result = Unit.convert(%Unit.Gram{value: 1000}, Unit.Kilogram)
# Returns: %Unit.Kilogram{value: 1.0, ...}

# Convert volume units
result = Unit.convert(%Unit.Cup{value: 1}, Unit.Tablespoon)
# Returns: %Unit.Tablespoon{value: 16.0, ...}

# Attempting to convert units of different types will return an error
result = Unit.convert(%Unit.Gram{value: 1000}, Unit.Cup)
# Returns: {:error, "Cannot convert units of different types: Elixir.Unit.Weight and Elixir.Unit.Volume"}
```

### Parsing Units from Strings

Parse a unit from a string representation:

```elixir
# Parse integer values with units
result = Unit.parse("2 cups of flour")
# Returns: {%Unit.Cup{value: 2.0}, "of flour"}

# Parse decimal values with units
result = Unit.parse("1.5 kg of sugar")
# Returns: {%Unit.Kilogram{value: 1.5}, "of sugar"}

# Parse fraction values with units
result = Unit.parse("3/4 teaspoon of salt")
# Returns: {%Unit.Teaspoon{value: 0.75}, "of salt"}

# Handle cases with no units found
result = Unit.parse("No units here")
# Returns: {:error, "No units here"}
```

### Converting Units to Strings

Convert a unit to its string representation:

```elixir
# Convert a unit with value 1 to string (singular form)
result = Unit.to_string(%Unit.Gram{value: 1})
# Returns: "1 gram"

# Convert a unit with value > 1 to string (plural form)
result = Unit.to_string(%Unit.Gram{value: 2.5})
# Returns: "2.5 grams"

# Works with all unit types
result = Unit.to_string(%Unit.Cup{value: 1})
# Returns: "1 cup"

result = Unit.to_string(%Unit.Cup{value: 3})
# Returns: "3 cups"
```

## Available Measurements

### Volume Units

| Unit | Module | Alias | Milliliter Equivalent |
|------|--------|-------|----------------------|
| Teaspoon | `Unit.Teaspoon` | tsp | 4.9289 |
| Tablespoon | `Unit.Tablespoon` | tbsp | 14.7868 |
| Milliliter | `Unit.Milliliter` | ml | 1.0 |
| Cup | `Unit.Cup` | c | 236.5882 |
| Pint | `Unit.Pint` | pt | 473.1765 |
| Quart | `Unit.Quart` | qt | 946.3529 |
| Gallon | `Unit.Gallon` | gal | 3785.4118 |

### Weight Units

| Unit | Module | Alias | Milligram Equivalent |
|------|--------|-------|---------------------|
| Ounce | `Unit.Ounce` | oz | 28349.5231 |
| Gram | `Unit.Gram` | g | 1000.0 |
| Milligram | `Unit.Milligram` | mg | 1.0 |
| Pound | `Unit.Pound` | lb | 453592.37 |
| Kilogram | `Unit.Kilogram` | kg | 1000000.0 |

