defmodule UnitTest do
  use ExUnit.Case
  doctest Unit

  describe "add/2" do
    test "adds two weight units of the same type correctly" do
      result = Unit.add(%Unit.Gram{value: 1000}, %Unit.Kilogram{value: 1})
      assert %Unit.Gram{value: 2000.0} = result
      assert result.singular == "gram"
      assert result.plural == "grams"
      assert result.alias == "g"
      assert result.type == Unit.Weight
      assert result.ml == 1.0
    end

    test "adds two volume units of the same type correctly" do
      result = Unit.add(%Unit.Cup{value: 1}, %Unit.Tablespoon{value: 16})
      assert %Unit.Cup{value: 2.0} = result
      assert result.singular == "cup"
      assert result.plural == "cups"
      assert result.alias == "c"
      assert result.type == Unit.Volume
      assert result.ml == 236.5882365
    end

    test "returns error when adding units of different types" do
      result = Unit.add(%Unit.Gram{value: 1000}, %Unit.Cup{value: 1})
      assert {:error, "Cannot add units of different types: Elixir.Unit.Weight and Elixir.Unit.Volume"} = result
    end

    test "returns error when arguments are not unit structs" do
      result = Unit.add("not a unit", %Unit.Gram{value: 1000})
      assert {:error, "Both arguments must be unit structs with a type field"} = result

      result = Unit.add(%Unit.Gram{value: 1000}, "not a unit")
      assert {:error, "Both arguments must be unit structs with a type field"} = result
    end
  end
end
