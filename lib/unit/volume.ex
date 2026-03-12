defmodule Unit.Volume do
  # List of all volume unit modules
  @units [
    Unit.Teaspoon,
    Unit.Tablespoon,
    Unit.Milliliter,
    Unit.Cup,
    Unit.Pint,
    Unit.Quart,
    Unit.Gallon
  ]

  # Create a mapping of strings to modules
  @string_to_module_mapping Enum.reduce(@units, %{}, fn module, acc ->
                              struct_info = struct(module)
                              acc
                              |> Map.put(struct_info.singular, module)
                              |> Map.put(struct_info.plural, module)
                              |> Map.put(struct_info.alias, module)
                            end)

  def from_string(string) do
    Map.fetch(@string_to_module_mapping, string)
  end

  def from_string!(string) do
    Map.fetch!(@string_to_module_mapping, string)
  end

  def parse(string) do
    Unit.Parser.parse(string, @units)
  end

  def convert(amount, to) do
    new = struct(to)
    Map.put(new, :value, Float.round(amount.value * amount.ml / struct(to).ml, 4))
  end

  def add(left, right) do
    Map.put(left, :value, Float.round(left.value + (right.value * right.ml / left.ml), 4))
  end

  def subtract(left, right) do
    Map.put(left, :value, Float.round(left.value - (right.value * right.ml / left.ml), 4))
  end
end
