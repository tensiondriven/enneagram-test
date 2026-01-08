defmodule EnneagramWebWeb.Layouts.Auth do
  use EnneagramWebWeb, :html

  def auth(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={get_csrf_token()} />
        <.live_title default="EnneagramWeb" suffix=" · Phoenix Framework">
          {assigns[:page_title]}
        </.live_title>
        <link phx-track-static rel="stylesheet" href={~p"/assets/app.css"} />
        <script defer phx-track-static type="text/javascript" src={~p"/assets/app.js"}>
        </script>
      </head>
      <body class="bg-white">
        <header class="bg-blue-600 text-white px-4 py-4 shadow-md">
          <div class="container mx-auto flex justify-between items-center">
            <h1 class="text-2xl font-bold">Enneagram Test</h1>
            <div>
              <%= if @current_user do %>
                <span class="mr-4">Welcome, <%= @current_user %></span>
                <a href="/monitor" class="mr-4 text-white hover:text-gray-200">Monitor</a>
                <button phx-click="logout" class="bg-red-500 hover:bg-red-600 px-4 py-2 rounded text-sm">
                  Logout
                </button>
              <% else %>
                <span class="text-sm">Please select a user</span>
              <% end %>
            </div>
          </div>
        </header>

        <main class="container mx-auto px-4 py-8">
          <.flash_group flash={@flash} />
          {@inner_content}
        </main>
      </body>
    </html>
    """
  end
end
