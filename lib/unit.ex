defmodule Unit do
  @moduledoc """
  Documentation for `Unit`.
  """

  # List of all known unit modules for parsing
  @units [
    # Weight units
    Unit.Gram,
    Unit.Kilogram,
    Unit.Milligram,
    Unit.Ounce,
    Unit.Pound,

    # Volume units
    Unit.Teaspoon,
    Unit.Tablespoon,
    Unit.Milliliter,
    Unit.Cup,
    Unit.Pint,
    Unit.Quart,
    Unit.Gallon
  ]

  @doc """
  Parses a unit from a string. Takes the first occurrence of a unit in the string.
  Matches against unit singular, plural, and alias forms.
  Values can be integers, decimals, or fractions.
  Returns a tuple with the parsed unit and the rest of the string, or :error if nothing matches.

  ## Examples

      iex> Unit.parse("2 cups of flour")
      {%Unit.Cup{value: 2.0}, " of flour"}

      iex> Unit.parse("1.5 kg of sugar")
      {%Unit.Kilogram{value: 1.5}, " of sugar"}

      iex> Unit.parse("3/4 teaspoon of salt")
      {%Unit.Teaspoon{value: 0.75}, " of salt"}

      iex> Unit.parse("No units here")
      :error

  """
  def parse(string) do
    string
    |> Float.parse()
    |> parse_fragments(string)
    |> find_unit(string)
  end

  def parse_fragments(:error, string), do: parse_fraction(string)
  def parse_fragments({num, string}, _string) do
    case parse_fraction(string) do
      {numerator, denominator, rest} -> {num + (numerator / denominator), rest}
      {:error, rest} -> {num, String.trim_leading(rest, " ")}
      x -> x
    end
  end

  def parse_fraction(string) do
    [first | rest] =
      string
      |> String.trim_leading(" ")
      |> String.split(" ")

    case calculate_decimal(String.split(first, "/"), string) do
      {:error, _rest} -> {:error, string}
      {n, d, _} -> {n, d, Enum.join(rest, " ")}
    end
  end

  def calculate_decimal([_], string), do: {:error, string}
  def calculate_decimal([numerator, denominator], string) do
    with {n, ""} <- Integer.parse(numerator),
         {d, ""} <- Integer.parse(denominator) do
      {n, d, string}
    else
      _ -> {:error, string}
    end
  end

  def find_unit({:error, _rest}, string), do: {:error, string}
  def find_unit({amount, rest}, string) do
    [unit | rest2] = String.split(rest, " ")
    unit = String.downcase(unit)
    module = Enum.find(@units, fn u -> unit in [u.__struct__.singular, u.__struct__.plural, u.__struct__.alias] end)

    if module do
      {struct(module, value: amount), Enum.join(rest2, " ")}
    else
      {:error, string}
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
end
