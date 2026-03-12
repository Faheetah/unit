defmodule Unit.ParserTest do
  use ExUnit.Case

  describe "parse/2" do
    test "parses integer values with units correctly" do
      result = Unit.Parser.parse("2 cups of flour", [Unit.Cup])
      assert {%Unit.Cup{value: 2.0}, "of flour"} = result
    end

    test "parses decimal values with units correctly" do
      result = Unit.Parser.parse("1.5 kg of sugar", [Unit.Kilogram])
      assert {%Unit.Kilogram{value: 1.5}, "of sugar"} = result
    end

    test "parses fraction values with units correctly" do
      result = Unit.Parser.parse("3/4 teaspoon of salt", [Unit.Teaspoon])
      assert {%Unit.Teaspoon{value: 0.75}, "of salt"} = result
    end

    test "returns error when no units are found" do
      result = Unit.Parser.parse("No units here", [Unit.Gram])
      assert {:error, "No units here"} = result
    end

    test "returns error when units are not recognized" do
      result = Unit.Parser.parse("2 unknownunits of something", [Unit.Gram])
      assert {:error, "2 unknownunits of something"} = result
    end

    test "handles edge cases correctly" do
      # Test with extra spaces
      result = Unit.Parser.parse("  2   cups   of flour  ", [Unit.Cup])
      assert {%Unit.Cup{value: 2.0}, "  of flour  "} = result

      # Test mixed case units
      result = Unit.Parser.parse("2 CUPS of flour", [Unit.Cup])
      assert {%Unit.Cup{value: 2.0}, "of flour"} = result
    end

    test "parses numbers directly attached to units" do
      # Test weight units with no space
      result = Unit.Parser.parse("1kg sugar", [Unit.Kilogram])
      assert {%Unit.Kilogram{value: 1.0}, "sugar"} = result

      result = Unit.Parser.parse("2.5g salt", [Unit.Gram])
      assert {%Unit.Gram{value: 2.5}, "salt"} = result
    end
  end
end
