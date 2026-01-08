defmodule EnneagramWebWeb.HomeLive do
  use EnneagramWebWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    current_user = Map.get(session, "current_user")
    {:ok, assign(socket, current_user: current_user)}
  end

  @impl true
  def handle_event("select_user", %{"user" => user}, socket) do
    {:noreply,
     socket
     |> assign(current_user: user)
     |> put_session(:current_user, user)
     |> configure_session(renew: true)}
  end

  @impl true
  def handle_event("logout", _params, socket) do
    {:noreply,
     socket
     |> assign(current_user: nil)
     |> clear_session()}
  end

  @impl true
  def handle_event("start_test", _params, socket) do
    if socket.assigns.current_user do
      {:noreply, push_navigate(socket, to: ~p"/test")}
    else
      {:noreply, socket}
    end
  end
end