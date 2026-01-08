defmodule EnneagramWeb.PubSub do
  @moduledoc """
  The PubSub module for broadcasting real-time updates.
  """
  @topic "test_updates"

  @doc """
  Subscribe to test updates.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(EnneagramWeb.PubSub, @topic)
  end

  @doc """
  Broadcast a test update.
  """
  def broadcast_test_updated(test) do
    Phoenix.PubSub.broadcast!(
      EnneagramWeb.PubSub,
      @topic,
      {:test_updated, test}
    )
  end

  @doc """
  Broadcast a test completion.
  """
  def broadcast_test_completed(test) do
    Phoenix.PubSub.broadcast!(
      EnneagramWeb.PubSub,
      @topic,
      {:test_completed, test}
    )
  end
end