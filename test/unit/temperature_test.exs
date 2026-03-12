defmodule Unit.TemperatureTest do
  use ExUnit.Case

  describe "from_string/1" do
    test "converts singular temperature unit names to modules" do
      assert {:ok, Unit.Celsius} = Unit.Temperature.from_string("celsius")
      assert {:ok, Unit.Fahrenheit} = Unit.Temperature.from_string("fahrenheit")
      assert {:ok, Unit.Kelvin} = Unit.Temperature.from_string("kelvin")
    end

    test "converts plural temperature unit names to modules" do
      assert {:ok, Unit.Celsius} = Unit.Temperature.from_string("celsius")
      assert {:ok, Unit.Fahrenheit} = Unit.Temperature.from_string("fahrenheit")
      assert {:ok, Unit.Kelvin} = Unit.Temperature.from_string("kelvins")
    end

    test "converts temperature unit aliases to modules" do
      assert {:ok, Unit.Celsius} = Unit.Temperature.from_string("c")
      assert {:ok, Unit.Fahrenheit} = Unit.Temperature.from_string("f")
      assert {:ok, Unit.Kelvin} = Unit.Temperature.from_string("k")
    end

    test "returns error for non-existent temperature units" do
      assert :error = Unit.Temperature.from_string("nonexistent")
      assert :error = Unit.Temperature.from_string("xyz")
      assert :error = Unit.Temperature.from_string("")
    end
  end

  describe "from_string!/1" do
    test "converts temperature unit names to modules" do
      assert Unit.Celsius = Unit.Temperature.from_string!("celsius")
      assert Unit.Fahrenheit = Unit.Temperature.from_string!("fahrenheit")
      assert Unit.Kelvin = Unit.Temperature.from_string!("kelvin")
    end

    test "raises KeyError for non-existent temperature units" do
      assert_raise KeyError, fn -> Unit.Temperature.from_string!("nonexistent") end
      assert_raise KeyError, fn -> Unit.Temperature.from_string!("xyz") end
      assert_raise KeyError, fn -> Unit.Temperature.from_string!("") end
    end
  end

  describe "parse/1" do
    test "parses integer values with temperature units correctly" do
      result = Unit.Temperature.parse("25 celsius room temperature")
      assert {%Unit.Celsius{value: 25.0}, "room temperature"} = result
    end

    test "parses decimal values with temperature units correctly" do
      result = Unit.Temperature.parse("98.6 fahrenheit body temperature")
      assert {%Unit.Fahrenheit{value: 98.6}, "body temperature"} = result
    end

    test "parses fraction values with temperature units correctly" do
      result = Unit.Temperature.parse("37/10 celsius cold")
      assert {%Unit.Celsius{value: 3.7}, "cold"} = result
    end

    test "returns error when no temperature units are found" do
      result = Unit.Temperature.parse("No temperature units here")
      assert {:error, "No temperature units here"} = result
    end

    test "returns error when temperature units are not recognized" do
      result = Unit.Temperature.parse("25 unknownunits temperature")
      assert {:error, "25 unknownunits temperature"} = result
    end

    test "handles edge cases correctly" do
      # Test with extra spaces
      result = Unit.Temperature.parse("  25   celsius   room  ")
      assert {%Unit.Celsius{value: 25.0}, "  room  "} = result

      # Test mixed case units
      result = Unit.Temperature.parse("25 CELSIUS room")
      assert {%Unit.Celsius{value: 25.0}, "room"} = result

      # Test unit aliases
      result = Unit.Temperature.parse("25 c room temperature")
      assert {%Unit.Celsius{value: 25.0}, "room temperature"} = result

      result = Unit.Temperature.parse("98.6 f body temperature")
      assert {%Unit.Fahrenheit{value: 98.6}, "body temperature"} = result
    end

    test "parses numbers directly attached to temperature units" do
      # Test temperature units with no space
      result = Unit.Temperature.parse("25c room temperature")
      assert {%Unit.Celsius{value: 25.0}, "room temperature"} = result

      result = Unit.Temperature.parse("98.6f body temperature")
      assert {%Unit.Fahrenheit{value: 98.6}, "body temperature"} = result
    end
  end
end
