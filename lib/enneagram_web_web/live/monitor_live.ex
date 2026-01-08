defmodule EnneagramWebWeb.MonitorLive do
  use EnneagramWebWeb, :live_view

  alias EnneagramWeb.Assessment

  @impl true
  def render(assigns) do
    ~H"""
    <main class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-6">Quiz Monitoring Dashboard</h1>

      <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex justify-between items-center mb-4">
          <h2 class="text-xl font-semibold">Active Sessions</h2>
          <span class="text-sm text-gray-500">
            Last updated: <%= @last_update |> monitor_format_time() %>
          </span>
        </div>

        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Test ID
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  User
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Started
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Progress
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Last Answer
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Confidence
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <%= for test <- @active_tests do %>
                <tr>
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    <%= test.id %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= test.user %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= test.started_at |> format_time() %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= length(test.answers) %> / <%= length(EnneagramWeb.Assessment.list_questions()) %> questions
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= monitor_get_last_answer(test) %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= test.confidence || 0 %>%
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>

        <%= if Enum.empty?(@active_tests) do %>
          <div class="text-center py-8 text-gray-500">
            No active quiz sessions currently
          </div>
        <% end %>
      </div>
    </main>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to test updates
      EnneagramWeb.PubSub.subscribe()

      # Set up periodic refresh
      :timer.send_interval(5000, :refresh_tests)
    end

    # Get all active tests
    active_tests = Assessment.get_active_tests()

    {:ok,
     socket
     |> assign(:active_tests, active_tests)
     |> assign(:last_update, DateTime.utc_now())
     |> assign(:current_user, "Monitor")}
  end

  @impl true
  def handle_info({:test_updated, test}, socket) do
    # Update the test in the list
    active_tests = update_test_in_list(socket.assigns.active_tests, test)

    {:noreply,
     socket
     |> assign(:active_tests, active_tests)
     |> assign(:last_update, DateTime.utc_now())}
  end

  @impl true
  def handle_info({:test_completed, test}, socket) do
    # Remove completed test from the list
    active_tests = Enum.filter(socket.assigns.active_tests, fn t -> t.id != test.id end)

    {:noreply,
     socket
     |> assign(:active_tests, active_tests)
     |> assign(:last_update, DateTime.utc_now())}
  end

  @impl true
  def handle_info(:refresh_tests, socket) do
    # Periodically refresh the list
    active_tests = Assessment.get_active_tests()

    {:noreply,
     socket
     |> assign(:active_tests, active_tests)
     |> assign(:last_update, DateTime.utc_now())}
  end

  # Helper function to update test in the list
  defp update_test_in_list(tests, updated_test) do
    Enum.map(tests, fn test ->
      if test.id == updated_test.id do
        updated_test
      else
        test
      end
    end)
  end

  # Helper function to get last answer for a test
  defp get_last_answer(test) do
    case test.answers do
      [] -> "No answers yet"
      answers ->
        last_answer = List.last(answers)
        "Q#{last_answer.question.id}: #{last_answer.answer_value}"
    end
  end

  # Export helper functions for template
  def monitor_get_last_answer(test), do: get_last_answer(test)
  def monitor_format_time(datetime), do: format_time(datetime)
  def format_time(datetime), do: datetime |> DateTime.to_string() |> String.split(" ") |> Enum.at(1)
end