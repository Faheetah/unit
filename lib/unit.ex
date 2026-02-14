defmodule Unit do
  @moduledoc """
  Documentation for `Unit`.
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

  def parse(string), do: parse(string, @units)
  def parse_weight(string), do: parse(string, @weight)
  def parse_volume(string), do: parse(string, @volume)
  def parse_temperature(string), do: parse(string, @temperature)

  @doc """
  Parses a unit from a string. Takes the first occurrence of a unit in the string.
  Matches against unit singular, plural, and alias forms.
  Values can be integers, decimals, or fractions.
  Returns a tuple with the parsed unit and the rest of the string, or {:error, string} if nothing matches.

  ## Examples

      iex> Unit.parse("2 cups of flour")
      {%Unit.Cup{value: 2.0}, "of flour"}

      iex> Unit.parse("1.5 kg of sugar")
      {%Unit.Kilogram{value: 1.5}, "of sugar"}

      iex> Unit.parse("3/4 teaspoon of salt")
      {%Unit.Teaspoon{value: 0.75}, "of salt"}

      iex> Unit.parse("1 notfound here")
      {:error, "1 notfound here"}

      iex> Unit.parse("3/4 notfound here")
      {:error, "3/4 notfound here"}

      iex> Unit.parse("No units here")
      {:error, "No units here"}

  """
  def parse(string, units) do
    # Try to parse as a fraction first
    case parse_fraction(string) do
      {numerator, denominator, rest} ->
        find_unit({(numerator / denominator), rest}, string, units)
      _ ->
        # If not a fraction, try parsing as a float
        # First trim leading spaces
        trimmed_string = String.trim_leading(string)
        case Float.parse(trimmed_string) do
          {num, rest} ->
            find_unit({num, rest}, string, units)
          :error ->
            # If Float.parse fails, try to parse just the numeric part
            parse_numeric_prefix(trimmed_string, string, units)
        end
    end
  end

  defp parse_fragments(:error, string), do: parse_fraction(string)
  defp parse_fragments({num, string}, _string) do
    case parse_fraction(string) do
      {numerator, denominator, rest} -> {num + (numerator / denominator), rest}
      {:error, rest} -> {num, String.trim_leading(rest, " ")}
      x -> x
    end
  end

  defp parse_fraction(string) do
    # Trim leading spaces and split by spaces to get the first word and the rest
    trimmed_string = String.trim_leading(string)
    words = String.split(trimmed_string, " ", parts: 2)

    case words do
      [] -> {:error, string}
      [first] ->
        # Split the first word by "/" to check if it's a fraction
        parts = String.split(first, "/")
        calculate_decimal(parts, "", string)
      [first | [rest]] ->
        # Split the first word by "/" to check if it's a fraction
        parts = String.split(first, "/")
        calculate_decimal(parts, rest, string)
    end
  end

  defp calculate_decimal([_], _rest, string), do: {:error, string}
  defp calculate_decimal([numerator, denominator], rest_string, string) do
    with {n, ""} <- Integer.parse(numerator),
         {d, ""} <- Integer.parse(denominator) do
      {n, d, rest_string}
    else
      _ -> {:error, string}
    end
  end

  defp find_unit({:error, _rest}, string, _units), do: {:error, string}
  defp find_unit({amount, rest}, string, units) do
    # First try to split by whitespace
    case String.split(String.trim_leading(rest), " ", parts: 2) do
      [unit | rest2] ->
        unit = String.downcase(unit)
        module = Enum.find(units, fn u ->
          singular = String.downcase(u.__struct__().singular)
          plural = String.downcase(u.__struct__().plural)
          alias_val = String.downcase(u.__struct__().alias)
          unit in [singular, plural, alias_val]
        end)

        if module do
          {struct(module, value: amount), Enum.join(rest2, " ")}
        else
          # If no match found, try to find unit directly attached to number
          find_attached_unit({amount, rest}, string, units)
        end
      [] ->
        # No spaces found, try to find unit directly attached to number
        find_attached_unit({amount, rest}, string, units)
    end
  end

  defp find_attached_unit({amount, rest}, string, units) do
    # Look for units that might be directly attached to the number
    module = Enum.find(units, fn u ->
      alias_val = String.downcase(u.__struct__().alias)
      String.starts_with?(String.downcase(rest), alias_val)
    end)

    if module do
      alias_val = String.downcase(module.__struct__().alias)
      rest_after_unit = String.slice(rest, String.length(alias_val)..-1)
      rest_after_unit = String.trim_leading(rest_after_unit, " ")
      {struct(module, value: amount), rest_after_unit}
    else
      {:error, string}
    end
  end

  defp parse_numeric_prefix(string, original_string, units) do
    # Try to parse just the numeric prefix
    case parse_number_prefix(string) do
      {num, rest} ->
        find_attached_unit({num, rest}, original_string, units)
      :error ->
        {:error, original_string}
    end
  end

  defp parse_number_prefix(string) do
    # Try to parse an integer or float prefix
    case Integer.parse(string) do
      {num, rest} -> {num * 1.0, rest}
      :error ->
        # Try to parse as float
        case Float.parse(string) do
          {num, rest} -> {num, rest}
          :error -> :error
        end
    end
  end

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
