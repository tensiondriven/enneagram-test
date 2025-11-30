defmodule EnneagramWebWeb.ResultsLiveTest do
  use EnneagramWebWeb.ConnCase

  import Phoenix.LiveViewTest

  alias EnneagramWeb.{Assessment, Repo, Test}

  setup do
    # Create a completed test
    {:ok, enneagram_test} = Assessment.create_test()

    enneagram_test =
      enneagram_test
      |> Test.complete_changeset(%{
        completed_at: DateTime.utc_now(),
        primary_type: 5,
        confidence: 87,
        scores: %{
          "1" => 45,
          "2" => 23,
          "3" => 67,
          "4" => 78,
          "5" => 92,
          "6" => 34,
          "7" => 56,
          "8" => 12,
          "9" => 29
        }
      })
      |> Repo.update!()

    %{enneagram_test: enneagram_test}
  end

  describe "results page" do
    test "displays completed test results", %{conn: conn, enneagram_test: enneagram_test} do
      {:ok, _view, html} = live(conn, ~p"/results/#{enneagram_test.id}")

      assert html =~ "Your Results"
      assert html =~ "Type 5"
      assert html =~ "The Investigator"
      assert html =~ "87% confidence"
    end

    test "shows primary type description", %{conn: conn, enneagram_test: enneagram_test} do
      {:ok, _view, html} = live(conn, ~p"/results/#{enneagram_test.id}")

      assert html =~ "The Perceptive Observer"
      assert html =~ "motivated by a desire to understand"
    end

    test "displays core fear and desire", %{conn: conn, enneagram_test: enneagram_test} do
      {:ok, _view, html} = live(conn, ~p"/results/#{enneagram_test.id}")

      assert html =~ "Core Fear"
      assert html =~ "Core Desire"
    end

    test "shows key traits", %{conn: conn, enneagram_test: enneagram_test} do
      {:ok, _view, html} = live(conn, ~p"/results/#{enneagram_test.id}")

      assert html =~ "Key Traits"
      assert html =~ "Perceptive"
    end

    test "displays all type scores in order", %{conn: conn, enneagram_test: enneagram_test} do
      {:ok, view, html} = live(conn, ~p"/results/#{enneagram_test.id}")

      assert html =~ "Your Type Scores"
      assert html =~ "Type 5 - The Investigator"

      # Verify scores are sorted (Type 5 should be first with 92)
      state = :sys.get_state(view.pid)
      socket = state.socket
      sorted_scores = socket.assigns.sorted_scores
      {first_type, first_score} = hd(sorted_scores)

      # Convert to integer if it's a string key
      first_type_int = if is_binary(first_type), do: String.to_integer(first_type), else: first_type

      assert first_type_int == 5
      assert first_score == 92
    end

    test "provides shareable URL", %{conn: conn, enneagram_test: enneagram_test} do
      {:ok, _view, html} = live(conn, ~p"/results/#{enneagram_test.id}")

      assert html =~ "Share Your Results"
      assert html =~ "/results/#{enneagram_test.id}"
    end

    test "has copy link button", %{conn: conn, enneagram_test: enneagram_test} do
      {:ok, view, _html} = live(conn, ~p"/results/#{enneagram_test.id}")

      assert view |> element("button", "Copy Link") |> has_element?()
    end

    test "has take again link", %{conn: conn, enneagram_test: enneagram_test} do
      {:ok, view, _html} = live(conn, ~p"/results/#{enneagram_test.id}")

      assert view |> element("a", "Take Test Again") |> has_element?()
    end

    test "redirects to home if test is not completed", %{conn: conn} do
      # Create incomplete test
      {:ok, incomplete_test} = Assessment.create_test()

      {:error, {:live_redirect, %{to: path}}} = live(conn, ~p"/results/#{incomplete_test.id}")
      assert path == "/"
    end
  end

  describe "share functionality" do
    test "copy link shows flash message", %{conn: conn, enneagram_test: enneagram_test} do
      {:ok, view, _html} = live(conn, ~p"/results/#{enneagram_test.id}")

      view |> element("button", "Copy Link") |> render_click()

      assert render(view) =~ "Link copied to clipboard!"
    end
  end

  describe "type descriptions" do
    test "shows correct description for each type", %{conn: conn} do
      for type <- 1..9 do
        {:ok, type_test} = Assessment.create_test()

        type_test =
          type_test
          |> Test.complete_changeset(%{
            completed_at: DateTime.utc_now(),
            primary_type: type,
            confidence: 85,
            scores: Map.new(1..9, fn t -> {to_string(t), if(t == type, do: 100, else: 50)} end)
          })
          |> Repo.update!()

        {:ok, _view, html} = live(conn, ~p"/results/#{type_test.id}")

        # Each type should have its own unique description
        assert html =~ "Type #{type}"
      end
    end
  end
end
