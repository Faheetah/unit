defmodule Unit.Temperature do
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
