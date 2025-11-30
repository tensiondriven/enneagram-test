defmodule EnneagramWeb.Scoring do
  @moduledoc """
  Scoring engine for Enneagram test that calculates type scores and confidence intervals.
  """

  @type_count 9
  @total_questions 70

  def calculate_scores(answers) do
    # Initialize all type scores to 0
    initial_scores = for type <- 1..@type_count, into: %{}, do: {type, 0}

    # Calculate raw scores for each type
    Enum.reduce(answers, initial_scores, fn answer, scores ->
      question = answer.question
      weights = EnneagramWeb.Question.weights(question)
      centered_value = answer.answer_value - 3  # Convert 1-5 to -2 to 2

      Enum.reduce(weights, scores, fn {type, weight}, acc ->
        Map.update!(acc, type, &(&1 + centered_value * weight))
      end)
    end)
  end

  def calculate_confidence(scores, questions_answered, _total_questions \\ @total_questions) do
    if questions_answered < 10 do
      {0, "Warming up..."}
    else
      gap_confidence = calculate_gap_confidence(scores)
      progress_confidence = calculate_progress_confidence(questions_answered)
      distribution_confidence = calculate_distribution_confidence(scores)

      # Weighted combination
      overall_confidence = (
        gap_confidence * 0.5 +
        progress_confidence * 0.3 +
        distribution_confidence * 0.2
      ) |> round()

      # Apply caps for edge cases
      confidence = apply_confidence_caps(overall_confidence, scores)

      {confidence, confidence_description(confidence)}
    end
  end

  defp calculate_gap_confidence(scores) do
    sorted_scores = scores
    |> Map.values()
    |> Enum.sort(:desc)

    case sorted_scores do
      [first, second | _] when first > 0 ->
        gap = (first - second) / max(first, 1)
        min(gap * 100, 100)
      _ ->
        0
    end
  end

  defp calculate_progress_confidence(questions_answered) do
    progress = questions_answered / @total_questions

    base_confidence = progress * 100

    cond do
      progress < 0.3 -> base_confidence * 0.5
      progress < 0.5 -> base_confidence * 0.75
      true -> base_confidence
    end
  end

  defp calculate_distribution_confidence(scores) do
    score_values = Map.values(scores)
    mean = Enum.sum(score_values) / length(score_values)

    if mean == 0 do
      0
    else
      std_dev = :math.sqrt(
        Enum.sum(Enum.map(score_values, fn x -> :math.pow(x - mean, 2) end)) /
        length(score_values)
      )

      coefficient_of_variation = std_dev / abs(mean)
      min(coefficient_of_variation * 50, 100)
    end
  end

  defp apply_confidence_caps(confidence, scores) do
    sorted_scores = scores
    |> Map.values()
    |> Enum.sort(:desc)

    # Check for tied scores
    confidence = case sorted_scores do
      [first, second | _] when first > 0 and abs(first - second) / first <= 0.05 ->
        min(confidence, 60)
      _ ->
        confidence
    end

    # Check for flat distribution
    max_score = Enum.max(sorted_scores)
    min_score = Enum.min(sorted_scores)

    if max_score > 0 and (max_score - min_score) / max_score <= 0.2 do
      min(confidence, 40)
    else
      confidence
    end
  end

  def confidence_description(confidence) do
    cond do
      confidence <= 30 -> "Just getting started..."
      confidence <= 50 -> "Forming a picture..."
      confidence <= 70 -> "Getting clearer..."
      confidence <= 85 -> "Pretty confident!"
      confidence <= 95 -> "Very confident!"
      true -> "Extremely confident!"
    end
  end

  def confidence_color(confidence) do
    cond do
      confidence <= 30 -> "text-gray-500"
      confidence <= 50 -> "text-yellow-500"
      confidence <= 70 -> "text-blue-400"
      confidence <= 85 -> "text-blue-600"
      confidence <= 95 -> "text-green-500"
      true -> "text-green-700"
    end
  end

  def get_primary_type(scores) do
    scores
    |> Enum.max_by(fn {_type, score} -> score end)
    |> elem(0)
  end

  def get_top_types(scores, count \\ 3) do
    scores
    |> Enum.sort_by(fn {_type, score} -> score end, :desc)
    |> Enum.take(count)
  end

  def normalize_scores(scores) do
    max_score = scores |> Map.values() |> Enum.max()
    min_score = scores |> Map.values() |> Enum.min()
    range = max_score - min_score

    if range == 0 do
      for type <- 1..@type_count, into: %{}, do: {type, 0}
    else
      for {type, score} <- scores, into: %{} do
        {type, round((score - min_score) / range * 100)}
      end
    end
  end

  def can_skip?(confidence, questions_answered) do
    questions_answered >= 40 and confidence >= 95
  end
end
