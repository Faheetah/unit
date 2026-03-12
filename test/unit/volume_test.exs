defmodule Unit.VolumeTest do
  use ExUnit.Case

  describe "from_string/1" do
    test "converts singular volume unit names to modules" do
      assert {:ok, Unit.Teaspoon} = Unit.Volume.from_string("teaspoon")
      assert {:ok, Unit.Tablespoon} = Unit.Volume.from_string("tablespoon")
      assert {:ok, Unit.Milliliter} = Unit.Volume.from_string("milliliter")
      assert {:ok, Unit.Cup} = Unit.Volume.from_string("cup")
      assert {:ok, Unit.Pint} = Unit.Volume.from_string("pint")
      assert {:ok, Unit.Quart} = Unit.Volume.from_string("quart")
      assert {:ok, Unit.Gallon} = Unit.Volume.from_string("gallon")
    end

    test "converts plural volume unit names to modules" do
      assert {:ok, Unit.Teaspoon} = Unit.Volume.from_string("teaspoons")
      assert {:ok, Unit.Tablespoon} = Unit.Volume.from_string("tablespoons")
      assert {:ok, Unit.Milliliter} = Unit.Volume.from_string("milliliters")
      assert {:ok, Unit.Cup} = Unit.Volume.from_string("cups")
      assert {:ok, Unit.Pint} = Unit.Volume.from_string("pints")
      assert {:ok, Unit.Quart} = Unit.Volume.from_string("quarts")
      assert {:ok, Unit.Gallon} = Unit.Volume.from_string("gallons")
    end

    test "converts volume unit aliases to modules" do
      assert {:ok, Unit.Teaspoon} = Unit.Volume.from_string("tsp")
      assert {:ok, Unit.Tablespoon} = Unit.Volume.from_string("tbsp")
      assert {:ok, Unit.Milliliter} = Unit.Volume.from_string("ml")
      assert {:ok, Unit.Cup} = Unit.Volume.from_string("c")
      assert {:ok, Unit.Pint} = Unit.Volume.from_string("pt")
      assert {:ok, Unit.Quart} = Unit.Volume.from_string("qt")
      assert {:ok, Unit.Gallon} = Unit.Volume.from_string("gal")
    end

    test "returns error for non-existent volume units" do
      assert :error = Unit.Volume.from_string("nonexistent")
      assert :error = Unit.Volume.from_string("xyz")
      assert :error = Unit.Volume.from_string("")
    end
  end

  describe "from_string!/1" do
    test "converts volume unit names to modules" do
      assert Unit.Teaspoon = Unit.Volume.from_string!("teaspoon")
      assert Unit.Tablespoon = Unit.Volume.from_string!("tablespoon")
      assert Unit.Milliliter = Unit.Volume.from_string!("milliliter")
      assert Unit.Cup = Unit.Volume.from_string!("cup")
      assert Unit.Pint = Unit.Volume.from_string!("pint")
      assert Unit.Quart = Unit.Volume.from_string!("quart")
      assert Unit.Gallon = Unit.Volume.from_string!("gallon")
    end

    test "raises KeyError for non-existent volume units" do
      assert_raise KeyError, fn -> Unit.Volume.from_string!("nonexistent") end
      assert_raise KeyError, fn -> Unit.Volume.from_string!("xyz") end
      assert_raise KeyError, fn -> Unit.Volume.from_string!("") end
    end
  end

  describe "parse/1" do
    test "parses integer values with volume units correctly" do
      result = Unit.Volume.parse("2 cups of flour")
      assert {%Unit.Cup{value: 2.0}, "of flour"} = result
    end

    test "parses decimal values with volume units correctly" do
      result = Unit.Volume.parse("1.5 liters of milk")
      assert {:error, "1.5 liters of milk"} = result
    end

    test "parses fraction values with volume units correctly" do
      result = Unit.Volume.parse("3/4 teaspoon of salt")
      assert {%Unit.Teaspoon{value: 0.75}, "of salt"} = result
    end

    test "returns error when no volume units are found" do
      result = Unit.Volume.parse("No volume units here")
      assert {:error, "No volume units here"} = result
    end

    test "returns error when volume units are not recognized" do
      result = Unit.Volume.parse("2 unknownunits of liquid")
      assert {:error, "2 unknownunits of liquid"} = result
    end

    test "handles edge cases correctly" do
      # Test with extra spaces
      result = Unit.Volume.parse("  2   cups   of flour  ")
      assert {%Unit.Cup{value: 2.0}, "  of flour  "} = result

      # Test mixed case units
      result = Unit.Volume.parse("2 CUPS of flour")
      assert {%Unit.Cup{value: 2.0}, "of flour"} = result

      # Test unit aliases
      result = Unit.Volume.parse("2 c of milk")
      assert {%Unit.Cup{value: 2.0}, "of milk"} = result

      result = Unit.Volume.parse("3 tsp of sugar")
      assert {%Unit.Teaspoon{value: 3.0}, "of sugar"} = result
    end

    test "parses numbers directly attached to volume units" do
      # Test volume units with no space
      result = Unit.Volume.parse("2c flour")
      assert {%Unit.Cup{value: 2.0}, "flour"} = result

      result = Unit.Volume.parse("3tsp sugar")
      assert {%Unit.Teaspoon{value: 3.0}, "sugar"} = result
    end
  end
end
