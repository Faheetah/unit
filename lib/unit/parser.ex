defmodule Unit.Parser do
  @moduledoc """
  Shared parsing functionality for unit modules.

  This module provides the core parsing logic used by all unit types to convert
  strings into unit structs. It handles parsing of numeric values (integers,
  decimals, and fractions) followed by unit identifiers.
  """

  @doc """
  Parses a unit from a string. Takes the first occurrence of a unit in the string.
  Matches against unit singular, plural, and alias forms.
  Values can be integers, decimals, or fractions.
  Returns a tuple with the parsed unit and the rest of the string, or {:error, string} if nothing matches.

  ## Examples

      iex> Unit.Parser.parse("2 cups of flour", [Unit.Cup])
      {%Unit.Cup{value: 2.0}, "of flour"}

      iex> Unit.Parser.parse("1.5 kg of sugar", [Unit.Kilogram])
      {%Unit.Kilogram{value: 1.5}, "of sugar"}

      iex> Unit.Parser.parse("3/4 teaspoon of salt", [Unit.Teaspoon])
      {%Unit.Teaspoon{value: 0.75}, "of salt"}

      iex> Unit.Parser.parse("No units here", [Unit.Gram])
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
end
