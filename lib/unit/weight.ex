defmodule Unit.Weight do
  @moduledoc """
  Functions for working with weight units.

  This module provides functions for converting between weight units
  (Gram, Kilogram, Milligram, Ounce, Pound) and parsing weight values from strings.
  """

  # List of all weight unit modules
  @units [
    Unit.Gram,
    Unit.Kilogram,
    Unit.Milligram,
    Unit.Ounce,
    Unit.Pound
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
  Converts a string to a weight unit module.

  Returns `{:ok, module}` if the string matches a known weight unit,
  or `:error` if no match is found.

  ## Examples

      iex> Unit.Weight.from_string("gram")
      {:ok, Unit.Gram}

      iex> Unit.Weight.from_string("kg")
      {:ok, Unit.Kilogram}

      iex> Unit.Weight.from_string("pound")
      {:ok, Unit.Pound}

      iex> Unit.Weight.from_string("unknown")
      :error

  """
  def from_string(string) do
    Map.fetch(@string_to_module_mapping, string)
  end

  @doc """
  Converts a string to a weight unit module.

  Returns the module if the string matches a known weight unit,
  or raises a KeyError if no match is found.

  ## Examples

      iex> Unit.Weight.from_string!("gram")
      Unit.Gram

      iex> Unit.Weight.from_string!("oz")
      Unit.Ounce

      iex> Unit.Weight.from_string!("kilogram")
      Unit.Kilogram

  """
  def from_string!(string) do
    Map.fetch!(@string_to_module_mapping, string)
  end

  @doc """
  Parses a weight value from a string.

  Returns a tuple with the parsed unit and the rest of the string,
  or `{:error, string}` if no weight unit is found.

  ## Examples

      iex> Unit.Weight.parse("2 kg of sugar")
      {%Unit.Kilogram{value: 2.0}, "of sugar"}

      iex> Unit.Weight.parse("1.5 pounds of flour")
      {%Unit.Pound{value: 1.5}, "of flour"}

      iex> Unit.Weight.parse("3/4 ounce of salt")
      {%Unit.Ounce{value: 0.75}, "of salt"}

      iex> Unit.Weight.parse("No weight here")
      {:error, "No weight here"}

  """
  def parse(string) do
    Unit.Parser.parse(string, @units)
  end

  def convert(amount, to) do
    new = struct(to)
    Map.put(new, :value, Float.round(amount.value * amount.mg / struct(to).mg, 4))
  end

  def add(left, right) do
    Map.put(left, :value, Float.round(left.value + (right.value * right.mg / left.mg), 4))
  end

  def subtract(left, right) do
    Map.put(left, :value, Float.round(left.value - (right.value * right.mg / left.mg), 4))
  end
end
