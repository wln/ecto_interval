defmodule EctoIntervalTest do
  use ExUnit.Case
  doctest EctoInterval

  test "load/1" do
    assert {:ok, %Postgrex.Interval{months: 0, days: 0, secs: 0}} =
             EctoInterval.load(%{months: 0, days: 0, secs: 0})

    assert {:ok, %Postgrex.Interval{months: 1, days: 2, secs: 3}} =
             EctoInterval.load(%{months: 1, days: 2, secs: 3})
  end

  describe "cast/1" do
    test "accept atom keys" do
      {:ok, %{months: 1, days: 2, secs: 3}} =
        EctoInterval.cast(%{months: "1", days: "2", secs: "3"})
    end

    test "accept string keys" do
      {:ok, %{months: 1, days: 2, secs: 3}} =
        EctoInterval.cast(%{"months" => 1, "days" => 2, "secs" => 3})
    end

    test "accept string values" do
      {:ok, %{months: 1, days: 2, secs: 3}} =
        EctoInterval.cast(%{"months" => "1", "days" => "2", "secs" => "3"})
    end

    test "accept integer values" do
      {:ok, %{months: 1, days: 2, secs: 3}} = EctoInterval.cast(%{months: 1, days: 2, secs: 3})
    end

    test "return :error in other cases" do
      :error = EctoInterval.cast(%{"months" => 1, days: 2, secs: 3})
      :error = EctoInterval.cast(%{months: 1, days: "1 day", secs: 3})
      :error = EctoInterval.cast(%{months: 1, days: 2, secs: :"3 sec"})
    end
  end

  test "to_string/1" do
    {:ok, none} = EctoInterval.load(%{months: 0, days: 0, secs: 0})
    {:ok, some} = EctoInterval.load(%{months: 1, days: 2, secs: 3})
    {:ok, usual} = EctoInterval.load(%{months: 24, days: 0, secs: 0})
    assert "<None>" = to_string(none)
    assert "Interval 1 months 2 days 3 seconds" = to_string(some)
    assert "Interval 24 months" = to_string(usual)
  end
end
