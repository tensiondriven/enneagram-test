defmodule EnneagramWebWeb.ResultsLive do
  use EnneagramWebWeb, :live_view

  alias EnneagramWeb.Assessment

  def mount(%{"id" => test_id}, _session, socket) do
    test = Assessment.get_test!(test_id)

    if is_nil(test.completed_at) do
      {:ok, push_navigate(socket, to: ~p"/")}
    else
      type_descriptions = get_type_descriptions()
      primary_type_desc = Map.get(type_descriptions, test.primary_type)

      # Sort scores for display
      sorted_scores = test.scores
      |> Enum.sort_by(fn {_, score} -> score end, :desc)

      {:ok,
       socket
       |> assign(:test, test)
       |> assign(:primary_type_desc, primary_type_desc)
       |> assign(:sorted_scores, sorted_scores)
       |> assign(:share_url, url(socket, ~p"/results/#{test_id}"))}
    end
  end

  def handle_event("copy_link", _params, socket) do
    {:noreply, socket |> put_flash(:info, "Link copied to clipboard!")}
  end

  defp get_type_descriptions do
    %{
      1 => %{
        name: "The Reformer",
        title: "The Principled Perfectionist",
        description: "You are motivated by a desire to be good, right, and to improve everything. You have strong principles, high standards, and a clear sense of right and wrong. At your best, you are wise, discerning, and noble.",
        core_fear: "Being wrong, bad, evil, or corrupt",
        core_desire: "To be good, balanced, and have integrity",
        key_traits: ["Principled", "Purposeful", "Self-controlled", "Perfectionistic", "Ethical", "Detail-oriented"]
      },
      2 => %{
        name: "The Helper",
        title: "The Caring Giver",
        description: "You are motivated by a need to be loved and needed by others. You are warm, empathetic, and generous, often putting others' needs before your own. At your best, you are unselfish and altruistic.",
        core_fear: "Being unwanted or unworthy of love",
        core_desire: "To feel loved and appreciated",
        key_traits: ["Generous", "Demonstrative", "People-pleasing", "Empathetic", "Warm", "Nurturing"]
      },
      3 => %{
        name: "The Achiever",
        title: "The Success-Oriented Performer",
        description: "You are motivated by a desire to be successful and admired. You are adaptable, excelling, and driven, with a strong focus on goals and image. At your best, you are authentic and inspiring.",
        core_fear: "Being worthless or failing",
        core_desire: "To feel valuable and worthwhile",
        key_traits: ["Adaptable", "Driven", "Image-conscious", "Competitive", "Efficient", "Goal-oriented"]
      },
      4 => %{
        name: "The Individualist",
        title: "The Sensitive Romantic",
        description: "You are motivated by a need to be unique, authentic, and to express yourself. You are expressive, creative, and sensitive, with deep emotional awareness. At your best, you are inspired and self-aware.",
        core_fear: "Being ordinary, flawed, or emotionally cut off",
        core_desire: "To find yourself and your significance",
        key_traits: ["Expressive", "Dramatic", "Creative", "Sensitive", "Moody", "Authentic"]
      },
      5 => %{
        name: "The Investigator",
        title: "The Perceptive Observer",
        description: "You are motivated by a desire to understand the world and to be capable. You are perceptive, innovative, and cerebral, with a need for knowledge and privacy. At your best, you are a pioneering visionary.",
        core_fear: "Being useless, helpless, or incompetent",
        core_desire: "To be knowledgeable and capable",
        key_traits: ["Perceptive", "Innovative", "Secretive", "Cerebral", "Curious", "Analytical"]
      },
      6 => %{
        name: "The Loyalist",
        title: "The Committed Skeptic",
        description: "You are motivated by a need for security and support. You are engaging, responsible, and loyal, but can be anxious and suspicious. At your best, you are courageous and self-reliant.",
        core_fear: "Being without support, guidance, or security",
        core_desire: "To have security and support",
        key_traits: ["Engaging", "Responsible", "Anxious", "Loyal", "Hardworking", "Prepared"]
      },
      7 => %{
        name: "The Enthusiast",
        title: "The Optimistic Adventurer",
        description: "You are motivated by a desire to be satisfied and content. You are spontaneous, versatile, and optimistic, always seeking new experiences. At your best, you are joyous and focused.",
        core_fear: "Being deprived, trapped in pain, or limited",
        core_desire: "To be happy, satisfied, and fulfilled",
        key_traits: ["Spontaneous", "Versatile", "Optimistic", "Excitable", "Adventurous", "Multi-talented"]
      },
      8 => %{
        name: "The Challenger",
        title: "The Powerful Protector",
        description: "You are motivated by a need to be strong and protect yourself. You are self-confident, decisive, and willful, with natural leadership abilities. At your best, you are heroic and magnanimous.",
        core_fear: "Being harmed, controlled, or violated",
        core_desire: "To protect yourself and determine your own course",
        key_traits: ["Self-confident", "Decisive", "Willful", "Confrontational", "Protective", "Direct"]
      },
      9 => %{
        name: "The Peacemaker",
        title: "The Easygoing Mediator",
        description: "You are motivated by a need for inner stability and peace of mind. You are receptive, reassuring, and agreeable, able to see all perspectives. At your best, you are deeply accepting and peaceful.",
        core_fear: "Loss, separation, and fragmentation",
        core_desire: "To have peace of mind and harmony",
        key_traits: ["Receptive", "Reassuring", "Agreeable", "Easygoing", "Supportive", "Peaceful"]
      }
    }
  end

  defp type_name(type_num) do
    desc = get_type_descriptions()[type_num]
    "Type #{type_num} - #{desc.name}"
  end
end
