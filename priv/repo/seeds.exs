# Script for populating the database

alias EnneagramWeb.{Repo, Question}

# Clear existing questions
Repo.delete_all(Question)

# Read CSV file
csv_path = Path.join([File.cwd!(), "research", "questions.csv"])

csv_path
|> File.stream!()
|> Stream.drop(1)  # Skip header
|> CSV.decode!(headers: false)
|> Enum.each(fn [id, question_text, t1, t2, t3, t4, t5, t6, t7, t8, t9, category] ->
  %Question{}
  |> Question.changeset(%{
    text: question_text,
    category: category,
    t1_weight: String.to_integer(t1),
    t2_weight: String.to_integer(t2),
    t3_weight: String.to_integer(t3),
    t4_weight: String.to_integer(t4),
    t5_weight: String.to_integer(t5),
    t6_weight: String.to_integer(t6),
    t7_weight: String.to_integer(t7),
    t8_weight: String.to_integer(t8),
    t9_weight: String.to_integer(t9)
  })
  |> Repo.insert!()

  IO.puts("Inserted question #{id}: #{String.slice(question_text, 0..50)}...")
end)

IO.puts("\n✅ Successfully seeded #{Repo.aggregate(Question, :count)} questions")
