defmodule EnneagramWeb.Assessment do
  import Ecto.Query
  alias EnneagramWeb.{Repo, Test, Answer, Question}

  def list_questions do
    Repo.all(from q in Question, order_by: [asc: q.id])
  end

  def get_question!(id), do: Repo.get!(Question, id)

  def create_test do
    %Test{}
    |> Test.changeset(%{started_at: DateTime.utc_now()})
    |> Repo.insert()
  end

  def get_test!(id) do
    Repo.get!(Test, id)
    |> Repo.preload(answers: :question)
  end

  def save_answer(test_id, question_id, answer_value) do
    %Answer{}
    |> Answer.changeset(%{
      test_id: test_id,
      question_id: question_id,
      answer_value: answer_value,
      answered_at: DateTime.utc_now()
    })
    |> Repo.insert(
      on_conflict: {:replace, [:answer_value, :answered_at]},
      conflict_target: [:test_id, :question_id]
    )
  end

  def complete_test(test, scores, primary_type, confidence, confidence_progression) do
    test
    |> Test.complete_changeset(%{
      completed_at: DateTime.utc_now(),
      scores: scores,
      primary_type: primary_type,
      confidence: confidence,
      confidence_progression: confidence_progression
    })
    |> Repo.update()
  end

  def get_test_answers(test_id) do
    Repo.all(
      from a in Answer,
      where: a.test_id == ^test_id,
      preload: [:question],
      order_by: [asc: a.answered_at]
    )
  end

  def seed_questions(questions) do
    Enum.each(questions, fn question_attrs ->
      %Question{}
      |> Question.changeset(question_attrs)
      |> Repo.insert!()
    end)
  end
end
