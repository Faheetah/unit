defmodule UnitTest do
  use ExUnit.Case
  doctest Unit

  test "greets the world" do
    assert Unit.hello() == :world
  end

  describe "split_on_float/1" do
    test "splits a string when it finds a float" do
      assert Unit.split_on_float("abc123.456def") == ["abc", "123.456", "def"]
    end

    test "returns the original string when no floats are found" do
      assert Unit.split_on_float("no numbers here") == ["no numbers here"]
    end

    test "handles a string that is just a float" do
      assert Unit.split_on_float("123.456") == ["123.456"]
    end

    test "handles multiple floats in a string" do
      assert Unit.split_on_float("start123.456middle789.012end") == ["start", "123.456", "middle", "789.012", "end"]
    end

    test "handles negative floats" do
      assert Unit.split_on_float("test-456.789example") == ["test", "-456.789", "example"]
    end

    test "handles floats with no leading digits" do
      assert Unit.split_on_float("test.123example") == ["test", ".123", "example"]
    end

    test "handles floats with no trailing digits" do
      assert Unit.split_on_float("test123.example") == ["test", "123.", "example"]
    end
  end
end
