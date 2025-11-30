defmodule EnneagramWeb.ScoringTest do
  use EnneagramWeb.DataCase

  alias EnneagramWeb.{Scoring, Question, Answer}

  describe "calculate_scores/1" do
    test "calculates scores based on question weights and answer values" do
      question = %Question{
        id: 1,
        t1_weight: 3,
        t2_weight: -1,
        t3_weight: 0,
        t4_weight: 2,
        t5_weight: 0,
        t6_weight: 0,
        t7_weight: 0,
        t8_weight: 0,
        t9_weight: 0
      }

      # Answer with value 5 (Strongly Agree)
      # Centered: 5 - 3 = 2
      answer = %Answer{
        question: question,
        answer_value: 5
      }

      scores = Scoring.calculate_scores([answer])

      # Type 1: 2 * 3 = 6
      # Type 2: 2 * -1 = -2
      # Type 4: 2 * 2 = 4
      assert scores[1] == 6
      assert scores[2] == -2
      assert scores[3] == 0
      assert scores[4] == 4
    end

    test "handles neutral answers (value 3)" do
      question = %Question{
        id: 1,
        t1_weight: 3,
        t2_weight: -2,
        t3_weight: 1,
        t4_weight: 0,
        t5_weight: 0,
        t6_weight: 0,
        t7_weight: 0,
        t8_weight: 0,
        t9_weight: 0
      }

      answer = %Answer{
        question: question,
        answer_value: 3  # Neutral
      }

      scores = Scoring.calculate_scores([answer])

      # Centered: 3 - 3 = 0, all scores should be 0
      assert scores[1] == 0
      assert scores[2] == 0
      assert scores[3] == 0
    end

    test "accumulates scores from multiple answers" do
      q1 = %Question{id: 1, t1_weight: 3, t2_weight: 0, t3_weight: 0, t4_weight: 0, t5_weight: 0, t6_weight: 0, t7_weight: 0, t8_weight: 0, t9_weight: 0}
      q2 = %Question{id: 2, t1_weight: 2, t2_weight: 0, t3_weight: 0, t4_weight: 0, t5_weight: 0, t6_weight: 0, t7_weight: 0, t8_weight: 0, t9_weight: 0}

      answers = [
        %Answer{question: q1, answer_value: 5},  # +6 for type 1
        %Answer{question: q2, answer_value: 4}   # +2 for type 1
      ]

      scores = Scoring.calculate_scores(answers)

      # Type 1 should accumulate: 6 + 2 = 8
      assert scores[1] == 8
    end
  end

  describe "calculate_confidence/3" do
    test "returns 0 confidence for less than 10 questions" do
      scores = %{1 => 10, 2 => 5, 3 => 3, 4 => 2, 5 => 1, 6 => 0, 7 => 0, 8 => 0, 9 => 0}

      {confidence, text} = Scoring.calculate_confidence(scores, 5, 70)

      assert confidence == 0
      assert text == "Warming up..."
    end

    test "calculates confidence with clear leader" do
      # Very clear winner
      scores = %{1 => 100, 2 => 20, 3 => 15, 4 => 10, 5 => 5, 6 => 0, 7 => 0, 8 => 0, 9 => 0}

      {confidence, _text} = Scoring.calculate_confidence(scores, 50, 70)

      assert confidence > 50
    end

    test "lowers confidence for tied scores" do
      # Two types very close
      scores = %{1 => 100, 2 => 98, 3 => 20, 4 => 10, 5 => 5, 6 => 0, 7 => 0, 8 => 0, 9 => 0}

      {confidence, _text} = Scoring.calculate_confidence(scores, 50, 70)

      # Should cap at 60% due to tie
      assert confidence <= 60
    end

    test "lowers confidence for flat distribution" do
      # All scores similar
      scores = %{1 => 50, 2 => 48, 3 => 47, 4 => 46, 5 => 45, 6 => 44, 7 => 43, 8 => 42, 9 => 41}

      {confidence, _text} = Scoring.calculate_confidence(scores, 50, 70)

      # Should cap at 40% due to flat distribution
      assert confidence <= 40
    end

    test "returns appropriate text for confidence levels" do
      scores = %{1 => 100, 2 => 20, 3 => 10, 4 => 5, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0}

      # With clear leader, confidence may be higher than just getting started
      {conf, text} = Scoring.calculate_confidence(scores, 15, 70)
      assert conf >= 0
      assert text in ["Just getting started...", "Forming a picture...", "Getting clearer..."]

      # Medium confidence
      {conf, text} = Scoring.calculate_confidence(scores, 40, 70)
      assert conf >= 30
      assert text in ["Forming a picture...", "Getting clearer...", "Pretty confident!"]
    end
  end

  describe "get_primary_type/1" do
    test "returns type with highest score" do
      scores = %{1 => 10, 2 => 50, 3 => 30, 4 => 20, 5 => 5, 6 => 0, 7 => 0, 8 => 0, 9 => 0}

      primary = Scoring.get_primary_type(scores)

      assert primary == 2
    end

    test "handles negative scores" do
      scores = %{1 => -10, 2 => -5, 3 => 0, 4 => -20, 5 => -15, 6 => -30, 7 => -2, 8 => -8, 9 => -25}

      primary = Scoring.get_primary_type(scores)

      # Should return type with highest (least negative) score
      assert primary == 3
    end
  end

  describe "get_top_types/2" do
    test "returns top N types sorted by score" do
      scores = %{1 => 100, 2 => 80, 3 => 60, 4 => 40, 5 => 20, 6 => 10, 7 => 5, 8 => 2, 9 => 1}

      top_3 = Scoring.get_top_types(scores, 3)

      assert length(top_3) == 3
      assert [{1, 100}, {2, 80}, {3, 60}] == top_3
    end
  end

  describe "normalize_scores/1" do
    test "converts scores to 0-100 percentage range" do
      scores = %{1 => 50, 2 => 100, 3 => 25, 4 => 0, 5 => -25, 6 => 75, 7 => 10, 8 => 60, 9 => 40}

      normalized = Scoring.normalize_scores(scores)

      # Type 2 (highest) should be 100%
      assert normalized[2] == 100
      # Type 5 (lowest) should be 0%
      assert normalized[5] == 0
      # Others should be proportional
      assert normalized[1] == 60
    end

    test "handles all scores equal" do
      scores = %{1 => 50, 2 => 50, 3 => 50, 4 => 50, 5 => 50, 6 => 50, 7 => 50, 8 => 50, 9 => 50}

      normalized = Scoring.normalize_scores(scores)

      # All should be 0 when there's no range
      Enum.each(1..9, fn type ->
        assert normalized[type] == 0
      end)
    end
  end

  describe "can_skip?/2" do
    test "returns true when confidence high and enough questions" do
      assert Scoring.can_skip?(95, 40) == true
      assert Scoring.can_skip?(100, 50) == true
    end

    test "returns false when confidence too low" do
      assert Scoring.can_skip?(94, 40) == false
      assert Scoring.can_skip?(80, 50) == false
    end

    test "returns false when not enough questions" do
      assert Scoring.can_skip?(95, 39) == false
      assert Scoring.can_skip?(100, 30) == false
    end
  end

  describe "confidence_description/1" do
    test "returns correct description for each confidence band" do
      assert Scoring.confidence_description(25) == "Just getting started..."
      assert Scoring.confidence_description(45) == "Forming a picture..."
      assert Scoring.confidence_description(65) == "Getting clearer..."
      assert Scoring.confidence_description(80) == "Pretty confident!"
      assert Scoring.confidence_description(90) == "Very confident!"
      assert Scoring.confidence_description(98) == "Extremely confident!"
    end
  end

  describe "confidence_color/1" do
    test "returns correct Tailwind color class for each band" do
      assert Scoring.confidence_color(25) == "text-gray-500"
      assert Scoring.confidence_color(45) == "text-yellow-500"
      assert Scoring.confidence_color(65) == "text-blue-400"
      assert Scoring.confidence_color(80) == "text-blue-600"
      assert Scoring.confidence_color(90) == "text-green-500"
      assert Scoring.confidence_color(98) == "text-green-700"
    end
  end
end
