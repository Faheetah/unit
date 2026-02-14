defmodule UnitTest do
  use ExUnit.Case
  doctest Unit

  describe "parse/1" do
    test "parses integer values with units correctly" do
      result = Unit.parse("2 cups of flour")
      assert {%Unit.Cup{value: 2.0}, "of flour"} = result
      assert %Unit.Cup{value: 2.0, singular: "cup", plural: "cups", alias: "c"} = result |> elem(0)

      result = Unit.parse("5 kg of sugar")
      assert {%Unit.Kilogram{value: 5.0}, "of sugar"} = result
      assert %Unit.Kilogram{value: 5.0, singular: "kilogram", plural: "kilograms", alias: "kg"} = result |> elem(0)
    end

    test "parses decimal values with units correctly" do
      result = Unit.parse("1.5 kg of sugar")
      assert {%Unit.Kilogram{value: 1.5}, "of sugar"} = result
      assert %Unit.Kilogram{value: 1.5, singular: "kilogram", plural: "kilograms", alias: "kg"} = result |> elem(0)

      result = Unit.parse("0.75 cups of milk")
      assert {%Unit.Cup{value: 0.75}, "of milk"} = result
      assert %Unit.Cup{value: 0.75, singular: "cup", plural: "cups", alias: "c"} = result |> elem(0)
    end

    test "parses fraction values with units correctly" do
      result = Unit.parse("3/4 teaspoon of salt")
      assert {%Unit.Teaspoon{value: 0.75}, "of salt"} = result
      assert %Unit.Teaspoon{value: 0.75, singular: "teaspoon", plural: "teaspoons", alias: "tsp"} = result |> elem(0)

      result = Unit.parse("1/2 cup of butter")
      assert {%Unit.Cup{value: 0.5}, "of butter"} = result
      assert %Unit.Cup{value: 0.5, singular: "cup", plural: "cups", alias: "c"} = result |> elem(0)
    end

    test "returns error when no units are found" do
      result = Unit.parse("No units here")
      assert {:error, "No units here"} = result

      result = Unit.parse("")
      assert {:error, ""} = result

      result = Unit.parse("Just a random string")
      assert {:error, "Just a random string"} = result
    end

    test "returns error when units are not recognized" do
      result = Unit.parse("2 unknownunits of something")
      assert {:error, "2 unknownunits of something"} = result

      result = Unit.parse("5 xyz of something")
      assert {:error, "5 xyz of something"} = result
    end

    test "handles edge cases correctly" do
      # Test with extra spaces
      result = Unit.parse("  2   cups   of flour  ")
      assert {%Unit.Cup{value: 2.0}, "  of flour  "} = result

      # Test mixed case units
      result = Unit.parse("2 CUPS of flour")
      assert {%Unit.Cup{value: 2.0}, "of flour"} = result

      # Test unit aliases
      result = Unit.parse("2 kg of sugar")
      assert {%Unit.Kilogram{value: 2.0}, "of sugar"} = result

      result = Unit.parse("3 c of milk")
      assert {%Unit.Cup{value: 3.0}, "of milk"} = result
    end
  end

  describe "add/2" do
    test "adds two weight units of the same type correctly" do
      result = Unit.add(%Unit.Gram{value: 1000}, %Unit.Kilogram{value: 1})
      assert %Unit.Gram{value: 2000.0} = result
      assert result.singular == "gram"
      assert result.plural == "grams"
      assert result.alias == "g"
      assert result.type == Unit.Weight
      assert result.mg == 1000.0
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

  describe "subtract/2" do
    test "subtracts two weight units of the same type correctly" do
      result = Unit.subtract(%Unit.Kilogram{value: 1}, %Unit.Gram{value: 500})
      assert %Unit.Kilogram{value: 0.5} = result
      assert result.singular == "kilogram"
      assert result.plural == "kilograms"
      assert result.alias == "kg"
      assert result.type == Unit.Weight
      assert result.mg == 1000000.0
    end

    test "subtracts two volume units of the same type correctly" do
      result = Unit.subtract(%Unit.Cup{value: 2}, %Unit.Tablespoon{value: 16})
      assert %Unit.Cup{value: 1.0} = result
      assert result.singular == "cup"
      assert result.plural == "cups"
      assert result.alias == "c"
      assert result.type == Unit.Volume
      assert result.ml == 236.5882365
    end

    test "returns error when subtracting units of different types" do
      result = Unit.subtract(%Unit.Gram{value: 1000}, %Unit.Cup{value: 1})
      assert {:error, "Cannot subtract units of different types: Elixir.Unit.Weight and Elixir.Unit.Volume"} = result
    end

    test "returns error when arguments are not unit structs" do
      result = Unit.subtract("not a unit", %Unit.Gram{value: 1000})
      assert {:error, "Both arguments must be unit structs with a type field"} = result

      result = Unit.subtract(%Unit.Gram{value: 1000}, "not a unit")
      assert {:error, "Both arguments must be unit structs with a type field"} = result
    end
  end

  describe "convert/2" do
    test "converts weight units correctly" do
      result = Unit.convert(%Unit.Gram{value: 1000}, Unit.Kilogram)
      assert %Unit.Kilogram{value: 1.0} = result
      assert result.singular == "kilogram"
      assert result.plural == "kilograms"
      assert result.alias == "kg"
      assert result.type == Unit.Weight
      assert result.mg == 1000000.0
    end

    test "converts to milligram units correctly" do
      result = Unit.convert(%Unit.Gram{value: 1}, Unit.Milligram)
      assert %Unit.Milligram{value: 1000.0} = result
      assert result.singular == "milligram"
      assert result.plural == "milligrams"
      assert result.alias == "mg"
      assert result.type == Unit.Weight
      assert result.mg == 1.0
    end

    test "converts volume units correctly" do
      result = Unit.convert(%Unit.Cup{value: 1}, Unit.Tablespoon)
      assert %Unit.Tablespoon{} = result
      assert abs(result.value - 16.0) < 0.0001
      assert result.singular == "tablespoon"
      assert result.plural == "tablespoons"
      assert result.alias == "tbsp"
      assert result.type == Unit.Volume
      assert result.ml == 14.78676484375
    end

    test "returns error when converting units of different types" do
      result = Unit.convert(%Unit.Gram{value: 1000}, Unit.Cup)
      assert {:error, "Cannot convert units of different types: Elixir.Unit.Weight and Elixir.Unit.Volume"} = result
    end

    test "returns error when first argument is not a unit struct" do
      result = Unit.convert("not a unit", Unit.Kilogram)
      assert {:error, "First argument must be a unit struct with a type field"} = result
    end
  end

  describe "temperature conversions" do
    test "converts between Celsius and Fahrenheit correctly" do
      # Celsius to Fahrenheit
      result = Unit.convert(%Unit.Celsius{value: 0}, Unit.Fahrenheit)
      assert %Unit.Fahrenheit{} = result
      assert abs(result.value - 32.0) < 0.0001

      result = Unit.convert(%Unit.Fahrenheit{value: 32}, Unit.Celsius)
      assert %Unit.Celsius{} = result
      assert abs(result.value - 0.0) < 0.0001

      # Boiling point
      result = Unit.convert(%Unit.Celsius{value: 100}, Unit.Fahrenheit)
      assert %Unit.Fahrenheit{} = result
      assert abs(result.value - 212.0) < 0.0001

      result = Unit.convert(%Unit.Fahrenheit{value: 212}, Unit.Celsius)
      assert %Unit.Celsius{} = result
      assert abs(result.value - 100.0) < 0.0001
    end

    test "converts between Celsius and Kelvin correctly" do
      # Celsius to Kelvin
      result = Unit.convert(%Unit.Celsius{value: 0}, Unit.Kelvin)
      assert %Unit.Kelvin{} = result
      assert abs(result.value - 273.15) < 0.0001

      # Kelvin to Celsius
      result = Unit.convert(%Unit.Kelvin{value: 273.15}, Unit.Celsius)
      assert %Unit.Celsius{} = result
      assert abs(result.value - 0.0) < 0.0001

      # Room temperature
      result = Unit.convert(%Unit.Celsius{value: 25}, Unit.Kelvin)
      assert %Unit.Kelvin{} = result
      assert abs(result.value - 298.15) < 0.0001

      result = Unit.convert(%Unit.Kelvin{value: 298.15}, Unit.Celsius)
      assert %Unit.Celsius{} = result
      assert abs(result.value - 25.0) < 0.0001
    end

    test "converts between Fahrenheit and Kelvin correctly" do
      # Fahrenheit to Kelvin
      result = Unit.convert(%Unit.Fahrenheit{value: 32}, Unit.Kelvin)
      assert %Unit.Kelvin{} = result
      assert abs(result.value - 273.15) < 0.0001

      # Kelvin to Fahrenheit
      result = Unit.convert(%Unit.Kelvin{value: 273.15}, Unit.Fahrenheit)
      assert %Unit.Fahrenheit{} = result
      assert abs(result.value - 32.0) < 0.0001
    end

    test "returns error when converting temperature to other unit types" do
      result = Unit.convert(%Unit.Celsius{value: 25}, Unit.Gram)
      assert {:error, "Cannot convert units of different types: Elixir.Unit.Temperature and Elixir.Unit.Weight"} = result

      result = Unit.convert(%Unit.Gram{value: 1000}, Unit.Celsius)
      assert {:error, "Cannot convert units of different types: Elixir.Unit.Weight and Elixir.Unit.Temperature"} = result
    end
  end

  describe "temperature arithmetic" do
    test "adds temperature units correctly" do
      result = Unit.add(%Unit.Celsius{value: 20}, %Unit.Celsius{value: 5})
      assert %Unit.Celsius{value: 25.0} = result

      result = Unit.add(%Unit.Fahrenheit{value: 68}, %Unit.Fahrenheit{value: 10})
      assert %Unit.Fahrenheit{value: 78.0} = result
    end

    test "subtracts temperature units correctly" do
      result = Unit.subtract(%Unit.Celsius{value: 25}, %Unit.Celsius{value: 5})
      assert %Unit.Celsius{value: 20.0} = result

      result = Unit.subtract(%Unit.Fahrenheit{value: 78}, %Unit.Fahrenheit{value: 10})
      assert %Unit.Fahrenheit{value: 68.0} = result
    end

    test "returns error when adding/subtracting different unit types" do
      result = Unit.add(%Unit.Celsius{value: 25}, %Unit.Gram{value: 1000})
      assert {:error, "Cannot add units of different types: Elixir.Unit.Temperature and Elixir.Unit.Weight"} = result

      result = Unit.subtract(%Unit.Celsius{value: 25}, %Unit.Cup{value: 1})
      assert {:error, "Cannot subtract units of different types: Elixir.Unit.Temperature and Elixir.Unit.Volume"} = result
    end
  end

  describe "temperature parsing" do
    test "parses temperature units correctly using aliases" do
      # Parse Celsius using alias
      result = Unit.parse_temperature("25 c room temperature")
      assert {%Unit.Celsius{value: 25.0}, "room temperature"} = result

      # Parse Fahrenheit using alias
      result = Unit.parse_temperature("72 f room temperature")
      assert {%Unit.Fahrenheit{value: 72.0}, "room temperature"} = result

      # Parse Kelvin using alias
      result = Unit.parse_temperature("298 k room temperature")
      assert {%Unit.Kelvin{value: 298.0}, "room temperature"} = result
    end

    test "returns error when temperature units are not recognized" do
      result = Unit.parse_temperature("25 cel room temperature")
      assert {:error, "25 cel room temperature"} = result

      result = Unit.parse_temperature("72 fah room temperature")
      assert {:error, "72 fah room temperature"} = result
    end
  end

  describe "to_string/1" do
    test "converts unit structs to string representation correctly" do
      # Test singular form for value 1
      result = Unit.to_string(%Unit.Gram{value: 1})
      assert "1 gram" = result

      # Test singular form for value 1.0
      result = Unit.to_string(%Unit.Gram{value: 1.0})
      assert "1 gram" = result

      # Test plural form for integer values other than 1
      result = Unit.to_string(%Unit.Gram{value: 2})
      assert "2 grams" = result

      # Test plural form for float values
      result = Unit.to_string(%Unit.Gram{value: 2.5})
      assert "2.5 grams" = result

      # Test with volume units
      result = Unit.to_string(%Unit.Cup{value: 1})
      assert "1 cup" = result

      result = Unit.to_string(%Unit.Cup{value: 3})
      assert "3 cups" = result

      # Test with decimal values that have trailing zeros
      result = Unit.to_string(%Unit.Gram{value: 1.50})
      assert "1.5 grams" = result

      # Test with larger numbers
      result = Unit.to_string(%Unit.Kilogram{value: 10})
      assert "10 kilograms" = result
    end
  end
end
