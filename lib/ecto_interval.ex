if Code.ensure_loaded?(Postgrex) do
  defmodule EctoInterval do
    @moduledoc """
    This implements Interval support for Postgrex that used to be in Ecto but no longer is.
    """
    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    @impl true
    def type, do: Postgrex.Interval

    @impl true
    def cast(%{"months" => months, "days" => days, "secs" => secs, "microsecs" => microsecs}) do
      do_cast(months, days, secs, microsecs)
    end

    def cast(%{"months" => months, "days" => days, "secs" => secs}) do
      do_cast(months, days, secs, 0)
    end

    def cast(%{months: months, days: days, secs: secs, microsecs: microsecs}) do
      do_cast(months, days, secs, microsecs)
    end

    def cast(%{months: months, days: days, secs: secs}) do
      do_cast(months, days, secs, 0)
    end

    def cast(other) do
      :error
    end

    defp do_cast(months, days, secs, microsecs) do
      try do
        months = to_integer(months)
        days = to_integer(days)
        secs = to_integer(secs)
        microsecs = to_integer(microsecs)
        {:ok, %{months: months, days: days, secs: secs, microsecs: microsecs}}
      rescue
        _ -> :error
      end
    end

    defp to_integer(arg) when is_binary(arg) do
      String.to_integer(arg)
    end

    defp to_integer(arg) when is_integer(arg) do
      arg
    end

    @impl true
    def load(%{months: months, days: days, secs: secs, microsecs: microsecs}) do
      {:ok, %Postgrex.Interval{months: months, days: days, secs: secs, microsecs: microsecs}}
    end

    def load(%{months: months, days: days, secs: secs}) do
      {:ok, %Postgrex.Interval{months: months, days: days, secs: secs, microsecs: 0}}
    end


    @impl true
    def dump(%{months: months, days: days, secs: secs, microsecs: microsecs}) do
      {:ok, %Postgrex.Interval{months: months, days: days, secs: secs, microsecs: microsecs}}
    end

    def dump(%{"months" => months, "days" => days, "secs" => secs, "microsecs" => microsecs}) do
      {:ok, %Postgrex.Interval{months: months, days: days, secs: secs, microsecs: microsecs}}
    end

    def dump(%{months: months, days: days, secs: secs}) do
      {:ok, %Postgrex.Interval{months: months, days: days, secs: secs, microsecs: 0}}
    end

    def dump(%{"months" => months, "days" => days, "secs" => secs}) do
      {:ok, %Postgrex.Interval{months: months, days: days, secs: secs, microsecs: 0}}
    end
  end

  defimpl String.Chars, for: [Postgrex.Interval] do
    import Kernel, except: [to_string: 1]

    def to_string(%{:months => months, :days => days, :secs => secs, :microsecs => microsecs}) do
      secs_with_micro = case microsecs do
        0 -> secs
        _ -> secs + (microsecs / 1_000_000.0)
      end

      m =
        if months === 0 do
          ""
        else
          " #{months} months"
        end

      d =
        if days === 0 do
          ""
        else
          " #{days} days"
        end

      s =
        if secs_with_micro === 0 do
          ""
        else
          " #{secs_with_micro} seconds"
        end

      if months === 0 and days === 0 and secs_with_micro === 0 do
        "<None>"
      else
        "Interval#{m}#{d}#{s}"
      end
    end
  end

  defimpl Inspect, for: [Postgrex.Interval] do
    def inspect(inv, _opts) do
      inspect(Map.from_struct(inv))
    end
  end

  if Code.ensure_loaded?(Phoenix.HTML.Safe) do
    defimpl Phoenix.HTML.Safe, for: [Postgrex.Interval] do
      def to_iodata(inv) do
        to_string(inv)
      end
    end
  end
end
