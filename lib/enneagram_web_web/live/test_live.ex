defmodule EnneagramWebWeb.TestLive do
  use EnneagramWebWeb, :live_view

  alias EnneagramWeb.{Assessment, Scoring}

  def mount(_params, _session, socket) do
    {:ok, test} = Assessment.create_test()
    questions = Assessment.list_questions()

    {:ok,
     socket
     |> assign(:test, test)
     |> assign(:questions, questions)
     |> assign(:current_index, 0)
     |> assign(:scores, initialize_scores())
     |> assign(:confidence, 0)
     |> assign(:confidence_text, "Warming up...")
     |> assign(:top_types, [])
     |> assign(:can_skip, false)}
  end

  def handle_event("answer", %{"answer" => value}, socket) do
    answer_value = String.to_integer(value)
    current_question = Enum.at(socket.assigns.questions, socket.assigns.current_index)

    # Save answer
    Assessment.save_answer(
      socket.assigns.test.id,
      current_question.id,
      answer_value
    )

    # Get all answers and recalculate scores
    answers = Assessment.get_test_answers(socket.assigns.test.id)
    scores = Scoring.calculate_scores(answers)
    questions_answered = length(answers)

    {confidence, confidence_text} = Scoring.calculate_confidence(scores, questions_answered)
    top_types = Scoring.get_top_types(scores, 3)
    normalized_scores = Scoring.normalize_scores(scores)
    can_skip = Scoring.can_skip?(confidence, questions_answered)

    # Move to next question or complete test
    next_index = socket.assigns.current_index + 1

    if next_index >= length(socket.assigns.questions) do
      # Test complete
      primary_type = Scoring.get_primary_type(scores)

      Assessment.complete_test(
        socket.assigns.test,
        normalized_scores,
        primary_type,
        confidence,
        %{}  # confidence_progression - TODO: track this
      )

      {:noreply, push_navigate(socket, to: ~p"/results/#{socket.assigns.test.id}")}
    else
      {:noreply,
       socket
       |> assign(:current_index, next_index)
       |> assign(:scores, scores)
       |> assign(:confidence, confidence)
       |> assign(:confidence_text, confidence_text)
       |> assign(:top_types, top_types)
       |> assign(:can_skip, can_skip)}
    end
  end

  def handle_event("skip_to_results", _params, socket) do
    answers = Assessment.get_test_answers(socket.assigns.test.id)
    scores = Scoring.calculate_scores(answers)
    normalized_scores = Scoring.normalize_scores(scores)
    primary_type = Scoring.get_primary_type(scores)
    questions_answered = length(answers)
    {confidence, _} = Scoring.calculate_confidence(scores, questions_answered)

    Assessment.complete_test(
      socket.assigns.test,
      normalized_scores,
      primary_type,
      confidence,
      %{}
    )

    {:noreply, push_navigate(socket, to: ~p"/results/#{socket.assigns.test.id}")}
  end

  defp initialize_scores do
    for type <- 1..9, into: %{}, do: {type, 0}
  end

  defp type_name(type_num) do
    case type_num do
      {1, _} -> "Type 1 - The Reformer"
      {2, _} -> "Type 2 - The Helper"
      {3, _} -> "Type 3 - The Achiever"
      {4, _} -> "Type 4 - The Individualist"
      {5, _} -> "Type 5 - The Investigator"
      {6, _} -> "Type 6 - The Loyalist"
      {7, _} -> "Type 7 - The Enthusiast"
      {8, _} -> "Type 8 - The Challenger"
      {9, _} -> "Type 9 - The Peacemaker"
    end
  end
end
