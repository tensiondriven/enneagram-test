defmodule EnneagramWeb.Assessment do
  import Ecto.Query
  alias EnneagramWeb.{Repo, Test, Answer, Question}

  def list_questions do
    Repo.all(from q in Question, order_by: [asc: q.id])
  end

  def get_question!(id), do: Repo.get!(Question, id)

  def create_test(user) do
    %Test{}
    |> Test.changeset(%{user: user, started_at: DateTime.utc_now()})
    |> Repo.insert()
  end

  def get_test!(id) do
    Repo.get!(Test, id)
    |> Repo.preload(answers: :question)
  end

  def get_test_by_user(user) do
    Repo.get_by(Test, user: user, completed_at: nil)
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
    |> case do
      {:ok, answer} ->
        # Broadcast the update
        test = get_test!(test_id)
        EnneagramWeb.PubSub.broadcast_test_updated(test)
        {:ok, answer}
      {:error, changeset} ->
        {:error, changeset}
    end
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
    |> case do
      {:ok, completed_test} ->
        # Broadcast the completion
        EnneagramWeb.PubSub.broadcast_test_completed(completed_test)
        {:ok, completed_test}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def get_active_tests do
    Repo.all(
      from t in Test,
      where: is_nil(t.completed_at),
      order_by: [desc: t.started_at],
      preload: [answers: :question]
    )
  end
end
