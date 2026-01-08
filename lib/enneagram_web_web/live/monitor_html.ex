defmodule EnneagramWebWeb.Live.MonitorHTML do
  use EnneagramWebWeb, :html

  embed_templates "monitor/*"

  def format_time(datetime) do
    datetime
    |> NaiveDateTime.to_iso8601()
  end

  def monitor_format_time(datetime) do
    datetime
    |> format_time()
    |> String.split("T")
    |> List.first()
  end

  def monitor_get_last_answer(_test) do
    # This will be implemented in the live view
    "No answers yet"
  end
end