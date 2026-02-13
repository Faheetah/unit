defmodule Unit do
  @moduledoc """
  Documentation for `Unit`.
  """

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
      %Unit.Tablespoon{value: 15.999999932371955, singular: "tablespoon", plural: "tablespoons", alias: "tbsp", type: Unit.Volume, ml: 14.78676484375}

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
