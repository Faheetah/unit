defmodule Unit.Temperature do
  @moduledoc """
  Functions for working with temperature units.

  This module provides functions for converting between temperature units
  (Celsius, Fahrenheit, and) and parsing temperature values from strings.
  """

  # List of all temperature unit modules
  @units [
    Unit.Celsius,
    Unit.Fahrenheit,
    Unit.Kelvin
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
  Converts a string to a temperature unit module.

  Returns `{:ok, module}` if the string matches a known temperature unit,
  or `:error` if no match is found.

  ## Examples

      iex> Unit.Temperature.from_string("celsius")
      {:ok, Unit.Celsius}

      iex> Unit.Temperature.from_string("f")
      {:ok, Unit.Fahrenheit}

      iex> Unit.Temperature.from_string("kelvin")
      {:ok, Unit.Kelvin}

      iex> Unit.Temperature.from_string("unknown")
      :error

  """
  def from_string(string) do
    Map.fetch(@string_to_module_mapping, string)
  end

  @doc """
  Converts a string to a temperature unit module.

  Returns the module if the string matches a known temperature unit,
  or raises a KeyError if no match is found.

  ## Examples

      iex> Unit.Temperature.from_string!("celsius")
      Unit.Celsius

      iex> Unit.Temperature.from_string!("k")
      Unit.Kelvin

      iex> Unit.Temperature.from_string!("fahrenheit")
      Unit.Fahrenheit

  """
  def from_string!(string) do
    Map.fetch!(@string_to_module_mapping, string)
  end

  @doc """
  Parses a temperature value from a string.

  Returns a tuple with the parsed unit and the rest of the string,
  or `{:error, string}` if no temperature unit is found.

  ## Examples

      iex> Unit.Temperature.parse("25 celsius room temperature")
      {%Unit.Celsius{value: 25.0}, "room temperature"}

      iex> Unit.Temperature.parse("98.6 fahrenheit body temperature")
      {%Unit.Fahrenheit{value: 98.6}, "body temperature"}

      iex> Unit.Temperature.parse("273.15 kelvin absolute zero")
      {%Unit.Kelvin{value: 273.15}, "absolute zero"}

      iex> Unit.Temperature.parse("No temperature here")
      {:error, "No temperature here"}

  """
  def parse(string) do
    Unit.Parser.parse(string, @units)
  end

  def convert(amount, to) do
    new = struct(to)
    # Convert to Celsius as intermediate step, then to target unit
    celsius_value = to_celsius(amount)
    target_value = from_celsius(celsius_value, new)
    Map.put(new, :value, round_float(target_value))
  end

  def add(left, right) do
    # For temperature, addition doesn't make physical sense in most contexts
    # We'll implement it as adding the numerical values for consistency with other units
    Map.put(left, :value, round_float(left.value + right.value))
  end

  def subtract(left, right) do
    # For temperature, subtraction doesn't make physical sense in most contexts
    # We'll implement it as subtracting the numerical values for consistency with other units
    Map.put(left, :value, round_float(left.value - right.value))
  end

  # Private functions for temperature conversions
  defp to_celsius(%Unit.Celsius{value: value}), do: value
  defp to_celsius(%Unit.Fahrenheit{value: value}), do: (value - 32) * 5/9
  defp to_celsius(%Unit.Kelvin{value: value}), do: value - 273.15

  defp from_celsius(value, %Unit.Celsius{}), do: value
  defp from_celsius(value, %Unit.Fahrenheit{}), do: value * 9/5 + 32
  defp from_celsius(value, %Unit.Kelvin{}), do: value + 273.15

  # Helper function to round floats to 4 decimal places
  defp round_float(value) when is_integer(value), do: value + 0.0
  defp round_float(value) when is_float(value), do: Float.round(value, 4)
end
