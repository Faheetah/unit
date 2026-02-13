defmodule Unit.Volume do
  def convert(amount, to) do
    new = struct(to)
    Map.put(new, :value, amount.value / amount.ml * struct(to).ml)
  end

  def add(left, right) do
    Map.put(left, :value, Float.round(left.value + (right.value * right.ml / left.ml), 4))
  end

  def subtract(left, right) do
    Map.put(left, :value, Float.round(left.value - (right.value * right.ml / left.ml), 4))
  end
end
