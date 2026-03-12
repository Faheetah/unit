defmodule Unit.Volume do
  @moduledoc """
  Functions for working with volume units.

  This module provides functions for converting between volume units
  (Teaspoon, Tablespoon, Milliliter, Cup, Pint, Quart, Gallon) and parsing
  volume values from strings.
  """

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

  @doc """
  Converts a string to a volume unit module.

  Returns `{:ok, module}` if the string matches a known volume unit,
  or `:error` if no match is found.

  ## Examples

      iex> Unit.Volume.from_string("cup")
      {:ok, Unit.Cup}

      iex> Unit.Volume.from_string("tsp")
      {:ok, Unit.Teaspoon}

      iex> Unit.Volume.from_string("gallon")
      {:ok, Unit.Gallon}

      iex> Unit.Volume.from_string("unknown")
      :error

  """
  def from_string(string) do
    Map.fetch(@string_to_module_mapping, string)
  end

  @doc """
  Converts a string to a volume unit module.

  Returns the module if the string matches a known volume unit,
  or raises a KeyError if no match is found.

  ## Examples

      iex> Unit.Volume.from_string!("cup")
      Unit.Cup

      iex> Unit.Volume.from_string!("ml")
      Unit.Milliliter

      iex> Unit.Volume.from_string!("quart")
      Unit.Quart

  """
  def from_string!(string) do
    Map.fetch!(@string_to_module_mapping, string)
  end

  @doc """
  Parses a volume value from a string.

  Returns a tuple with the parsed unit and the rest of the string,
  or `{:error, string}` if no volume unit is found.

  ## Examples

      iex> Unit.Volume.parse("2 cups of flour")
      {%Unit.Cup{value: 2.0}, "of flour"}

      iex> Unit.Volume.parse("1.5 liters of milk")
      {:error, "1.5 liters of milk"}

      iex> Unit.Volume.parse("3/4 teaspoon of salt")
      {%Unit.Teaspoon{value: 0.75}, "of salt"}

      iex> Unit.Volume.parse("No volume here")
      {:error, "No volume here"}

  """
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
