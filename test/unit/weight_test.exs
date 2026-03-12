defmodule Unit.WeightTest do
  use ExUnit.Case

  describe "from_string/1" do
    test "converts singular weight unit names to modules" do
      assert {:ok, Unit.Gram} = Unit.Weight.from_string("gram")
      assert {:ok, Unit.Kilogram} = Unit.Weight.from_string("kilogram")
      assert {:ok, Unit.Milligram} = Unit.Weight.from_string("milligram")
      assert {:ok, Unit.Ounce} = Unit.Weight.from_string("ounce")
      assert {:ok, Unit.Pound} = Unit.Weight.from_string("pound")
    end

    test "converts plural weight unit names to modules" do
      assert {:ok, Unit.Gram} = Unit.Weight.from_string("grams")
      assert {:ok, Unit.Kilogram} = Unit.Weight.from_string("kilograms")
      assert {:ok, Unit.Milligram} = Unit.Weight.from_string("milligrams")
      assert {:ok, Unit.Ounce} = Unit.Weight.from_string("ounces")
      assert {:ok, Unit.Pound} = Unit.Weight.from_string("pounds")
    end

    test "converts weight unit aliases to modules" do
      assert {:ok, Unit.Gram} = Unit.Weight.from_string("g")
      assert {:ok, Unit.Kilogram} = Unit.Weight.from_string("kg")
      assert {:ok, Unit.Milligram} = Unit.Weight.from_string("mg")
      assert {:ok, Unit.Ounce} = Unit.Weight.from_string("oz")
      assert {:ok, Unit.Pound} = Unit.Weight.from_string("lb")
    end

    test "returns error for non-existent weight units" do
      assert :error = Unit.Weight.from_string("nonexistent")
      assert :error = Unit.Weight.from_string("xyz")
      assert :error = Unit.Weight.from_string("")
    end
  end

  describe "from_string!/1" do
    test "converts weight unit names to modules" do
      assert Unit.Gram = Unit.Weight.from_string!("gram")
      assert Unit.Kilogram = Unit.Weight.from_string!("kilogram")
      assert Unit.Milligram = Unit.Weight.from_string!("milligram")
      assert Unit.Ounce = Unit.Weight.from_string!("ounce")
      assert Unit.Pound = Unit.Weight.from_string!("pound")
    end

    test "raises KeyError for non-existent weight units" do
      assert_raise KeyError, fn -> Unit.Weight.from_string!("nonexistent") end
      assert_raise KeyError, fn -> Unit.Weight.from_string!("xyz") end
      assert_raise KeyError, fn -> Unit.Weight.from_string!("") end
    end
  end

  describe "parse/1" do
    test "parses integer values with weight units correctly" do
      result = Unit.Weight.parse("2 kg of sugar")
      assert {%Unit.Kilogram{value: 2.0}, "of sugar"} = result
    end

    test "parses decimal values with weight units correctly" do
      result = Unit.Weight.parse("1.5 pounds of flour")
      assert {%Unit.Pound{value: 1.5}, "of flour"} = result
    end

    test "parses fraction values with weight units correctly" do
      result = Unit.Weight.parse("3/4 ounce of salt")
      assert {%Unit.Ounce{value: 0.75}, "of salt"} = result
    end

    test "returns error when no weight units are found" do
      result = Unit.Weight.parse("No weight units here")
      assert {:error, "No weight units here"} = result
    end

    test "returns error when weight units are not recognized" do
      result = Unit.Weight.parse("2 unknownunits of material")
      assert {:error, "2 unknownunits of material"} = result
    end

    test "handles edge cases correctly" do
      # Test with extra spaces
      result = Unit.Weight.parse("  2   kg   of sugar  ")
      assert {%Unit.Kilogram{value: 2.0}, "  of sugar  "} = result

      # Test mixed case units
      result = Unit.Weight.parse("2 KG of sugar")
      assert {%Unit.Kilogram{value: 2.0}, "of sugar"} = result

      # Test unit aliases
      result = Unit.Weight.parse("2 g of salt")
      assert {%Unit.Gram{value: 2.0}, "of salt"} = result

      result = Unit.Weight.parse("3 oz of cheese")
      assert {%Unit.Ounce{value: 3.0}, "of cheese"} = result
    end

    test "parses numbers directly attached to weight units" do
      # Test weight units with no space
      result = Unit.Weight.parse("2kg sugar")
      assert {%Unit.Kilogram{value: 2.0}, "sugar"} = result

      result = Unit.Weight.parse("500g flour")
      assert {%Unit.Gram{value: 500.0}, "flour"} = result
    end
  end
end
