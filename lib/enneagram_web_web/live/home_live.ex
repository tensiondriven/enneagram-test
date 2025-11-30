defmodule EnneagramWebWeb.HomeLive do
  use EnneagramWebWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("start_test", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/test")}
  end
end
