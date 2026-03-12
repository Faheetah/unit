defmodule Unit do
  @moduledoc """
  Main module for working with units of measurement.

  This module provides functions for parsing unit strings, converting between
  units, and performing arithmetic operations on units. Units are organized
  by type: Temperature, Volume, and Weight.

  ## Examples

      iex> Unit.parse("2 cups of flour")
      {%Unit.Cup{value: 2.0}, "of flour"}

      iex> Unit.parse("1.5 kg of sugar")
      {%Unit.Kilogram{value: 1.5}, "of sugar"}

      iex> Unit.parse("25 celsius room temperature")
      {%Unit.Celsius{value: 25.0}, "room temperature"}

      iex> Unit.add(%Unit.Gram{value: 1000}, %Unit.Kilogram{value: 1})
      %Unit.Gram{value: 2000.0, singular: "gram", plural: "grams", alias: "g", type: Unit.Weight, mg: 1000.0}

      iex> Unit.convert(%Unit.Cup{value: 1}, Unit.Tablespoon)
      %Unit.Tablespoon{value: 16.0, singular: "tablespoon", plural: "tablespoons", alias: "tbsp", type: Unit.Volume, ml: 14.78676484375}

  """

  # List of all known unit modules for parsing
  @weight [
    # Weight units
    Unit.Gram,
    Unit.Kilogram,
    Unit.Milligram,
    Unit.Ounce,
    Unit.Pound
  ]

  @volume [
    # Volume units
    Unit.Teaspoon,
    Unit.Tablespoon,
    Unit.Milliliter,
    Unit.Cup,
    Unit.Pint,
    Unit.Quart,
    Unit.Gallon
  ]

  @temperature [
    # Temperature units
    Unit.Celsius,
    Unit.Fahrenheit,
    Unit.Kelvin
  ]

  @units @weight ++ @volume ++ @temperature

  @doc """
  Parses a unit from a string, detecting the unit type automatically.

  ## Examples

      iex> Unit.parse("2 cups of flour")
      {%Unit.Cup{value: 2.0}, "of flour"}

      iex> Unit.parse("1.5 kg of sugar")
      {%Unit.Kilogram{value: 1.5}, "of sugar"}

      iex> Unit.parse("25 celsius room temperature")
      {%Unit.Celsius{value: 25.0}, "room temperature"}

  """
  def parse(string), do: Unit.Parser.parse(string, @units)

  @doc """
  Parses a weight unit from a string.

  ## Examples

      iex> Unit.parse_weight("2 kg of sugar")
      {%Unit.Kilogram{value: 2.0}, "of sugar"}

  """
  def parse_weight(string), do: Unit.Parser.parse(string, @weight)

  @doc """
  Parses a volume unit from a string.

  ## Examples

      iex> Unit.parse_volume("2 cups of flour")
      {%Unit.Cup{value: 2.0}, "of flour"}

  """
  def parse_volume(string), do: Unit.Parser.parse(string, @volume)

  @doc """
  Parses a temperature unit from a string.

  ## Examples

      iex> Unit.parse_temperature("25 celsius room temperature")
      {%Unit.Celsius{value: 25.0}, "room temperature"}

  """
  def parse_temperature(string), do: Unit.Parser.parse(string, @temperature)

  @doc """
  Adds two units of the same type together.

  ## Examples

      iex> Unit.add(%Unit.Gram{value: 1000}, %Unit.Kilogram{value: 1})
      %Unit.Gram{value: 2000.0, singular: "gram", plural: "grams", alias: "g", type: Unit.Weight, mg: 1000.0}

      iex> Unit.add(%Unit.Cup{value: 1}, %Unit.Tablespoon{value: 16})
      %Unit.Cup{value: 2.0, singular: "cup", plural: "cups", alias: "c", type: Unit.Volume, ml: 236.5882365}

      iex> Unit.add(%Unit.Gram{value: 1000}, %Unit.Cup{value: 1})
      {:error, "Cannot add units of different types: Elixir.Unit.Weight and Elixir.Unit.Volume"}

  """
  def add(%{type: type1} = left, %{type: type2} = right) when type1 == type2 do
    type1.add(left, right)
  end

  def add(%{type: type1}, %{type: type2}) do
    {:error, "Cannot add units of different types: #{type1} and #{type2}"}
  end

  def add(_, _) do
    {:error, "Both arguments must be unit structs with a type field"}
  end

  @doc """
  Subtracts one unit from another unit of the same type.

  ## Examples

      iex> Unit.subtract(%Unit.Kilogram{value: 1}, %Unit.Gram{value: 500})
      %Unit.Kilogram{value: 0.5, singular: "kilogram", plural: "kilograms", alias: "kg", type: Unit.Weight, mg: 1000000.0}

      iex> Unit.subtract(%Unit.Cup{value: 2}, %Unit.Tablespoon{value: 16})
      %Unit.Cup{value: 1.0, singular: "cup", plural: "cups", alias: "c", type: Unit.Volume, ml: 236.5882365}

      iex> Unit.subtract(%Unit.Gram{value: 1000}, %Unit.Cup{value: 1})
      {:error, "Cannot subtract units of different types: Elixir.Unit.Weight and Elixir.Unit.Volume"}

  """
  def subtract(%{type: type1} = left, %{type: type2} = right) when type1 == type2 do
    type1.subtract(left, right)
  end

  def subtract(%{type: type1}, %{type: type2}) do
    {:error, "Cannot subtract units of different types: #{type1} and #{type2}"}
  end

  def subtract(_, _) do
    {:error, "Both arguments must be unit structs with a type field"}
  end

  @doc """
  Converts a unit to another unit of the same type.

  ## Examples

      iex> Unit.convert(%Unit.Gram{value: 1000}, Unit.Kilogram)
      %Unit.Kilogram{value: 1.0, singular: "kilogram", plural: "kilograms", alias: "kg", type: Unit.Weight, mg: 1000000.0}

      iex> Unit.convert(%Unit.Cup{value: 1}, Unit.Tablespoon)
      %Unit.Tablespoon{value: 16.0, singular: "tablespoon", plural: "tablespoons", alias: "tbsp", type: Unit.Volume, ml: 14.78676484375}

      iex> Unit.convert(%Unit.Gram{value: 1000}, Unit.Cup)
      {:error, "Cannot convert units of different types: Elixir.Unit.Weight and Elixir.Unit.Volume"}

  """
  def convert(%{type: type1} = amount, type2) do
    target_type = struct(type2).type
    if type1 == target_type do
      type1.convert(amount, type2)
    else
      {:error, "Cannot convert units of different types: #{type1} and #{target_type}"}
    end
  end

  def convert(_, _) do
    {:error, "First argument must be a unit struct with a type field"}
  end

  @doc """
  Converts a unit struct to its string representation.

  ## Examples

      iex> Unit.to_string(%Unit.Gram{value: 1})
      "1 gram"

      iex> Unit.to_string(%Unit.Gram{value: 2.5})
      "2.5 grams"

      iex> Unit.to_string(%Unit.Cup{value: 1})
      "1 cup"

      iex> Unit.to_string(%Unit.Cup{value: 3})
      "3 cups"
  """
  def to_string(%{value: value, singular: singular, plural: plural} = _unit) do
    unit_name = if value == 1 or value == 1.0, do: singular, else: plural
    # Format the value to avoid unnecessary decimal places
    formatted_value = if is_integer(value) or value == trunc(value) do
      Integer.to_string(trunc(value))
    else
      :erlang.float_to_binary(value, [{:decimals, 10}, :compact])
    end
    "#{formatted_value} #{unit_name}"
  end
end
