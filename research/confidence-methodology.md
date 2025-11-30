# Confidence Interval Methodology

## Overview
This document explains how we calculate and display confidence in the user's Enneagram type as they progress through the test. The goal is to give real-time feedback about how certain we are of their type, which makes the experience more engaging and transparent.

## Core Concept
Confidence is based on three factors:
1. **Score Separation** - How much does the leading type stand out from the others?
2. **Question Progress** - Have they answered enough questions for a reliable result?
3. **Score Distribution** - Are scores clearly differentiated or all bunched together?

## Calculation Method

### Step 1: Calculate Type Scores
For each of the 9 types, sum the weighted scores from answered questions.

For a 5-point Likert scale (1=Strongly Disagree to 5=Strongly Agree):
```
Answer value: 1, 2, 3, 4, 5
Centered value: -2, -1, 0, 1, 2 (subtract 3 to center around 0)
Type score += (centered_value × type_weight)
```

This means:
- Strongly Disagree on a +3 weighted question: -2 × 3 = -6 points
- Strongly Agree on a +3 weighted question: 2 × 3 = 6 points
- Neutral (3) adds 0 points regardless of weight

### Step 2: Normalize Scores
Convert raw scores to percentages of the maximum possible score:
```
normalized_score = (raw_score + max_possible_negative) / (max_possible_positive + max_possible_negative)
```

### Step 3: Calculate Gap Confidence
Measure the separation between the top type and second-place type:
```
gap = (score_1st - score_2nd) / score_1st
gap_confidence = min(gap × 100, 100)
```

If the leading type has 120 points and second place has 80:
- Gap = (120 - 80) / 120 = 0.33
- Gap confidence = 33%

### Step 4: Calculate Progress Confidence
Confidence based on how many questions have been answered:
```
progress = questions_answered / total_questions
progress_confidence = progress × 100

# Apply diminishing returns curve
if progress < 0.3:  # Less than 30% done
    progress_confidence *= 0.5
elif progress < 0.5:  # Less than 50% done
    progress_confidence *= 0.75
```

### Step 5: Calculate Distribution Confidence
How well-separated are all the scores?
```
std_dev = standard_deviation(all_9_scores)
mean_score = mean(all_9_scores)
coefficient_of_variation = std_dev / mean_score

# Higher CV = more spread out = more confident
distribution_confidence = min(coefficient_of_variation × 50, 100)
```

### Step 6: Combine into Overall Confidence
```
confidence = (
    gap_confidence × 0.5 +           # 50% weight - most important
    progress_confidence × 0.3 +       # 30% weight
    distribution_confidence × 0.2     # 20% weight
)

# Round to whole number
confidence = round(confidence)
```

## Display Rules

### Confidence Bands
- **0-30%**: "Just getting started..." (Gray)
- **31-50%**: "Forming a picture..." (Yellow)
- **51-70%**: "Getting clearer..." (Light Blue)
- **71-85%**: "Pretty confident!" (Blue)
- **86-95%**: "Very confident!" (Green)
- **96-100%**: "Extremely confident!" (Dark Green)

### Visual Representation
Show confidence as:
1. A percentage number (e.g., "78%")
2. A progress bar with color coding
3. A text description (e.g., "Pretty confident!")
4. Top 3 types with their current scores shown as percentages

### Example Display (Mobile)
```
┌─────────────────────────────────┐
│ Confidence: 78% ████████░░      │
│ Pretty confident!                │
│                                  │
│ Your likely type:                │
│ Type 5 - The Investigator  42%  │
│ Type 4 - The Individualist 31%  │
│ Type 1 - The Reformer      28%  │
│                                  │
│ Question 35 of 70                │
└─────────────────────────────────┘
```

## Early Stopping
If confidence reaches 95%+ after minimum 40 questions:
- Show optional "Skip to Results" button
- User can continue for more certainty or finish early
- Never force early exit - let user complete all questions if desired

## Minimum Questions Rule
Don't display confidence percentage until at least 10 questions answered.
Show "Warming up..." for first 10 questions.

## Edge Cases

### Tied Scores
If top 2 types are within 5% of each other:
- Confidence capped at 60% regardless of other factors
- Display: "Too close to call between Type X and Type Y"

### Flat Distribution
If all scores within 20% of each other:
- Confidence capped at 40%
- Suggest user continue answering questions

### Negative Scores
Some types may have negative scores if user strongly disagrees with that type's characteristics. This is normal and expected. Use absolute values when calculating distributions.

## Implementation Notes
- Recalculate confidence after each question answered
- Update UI smoothly (animate progress bar changes)
- Store calculation in session to show on results page
- Log confidence progression for analytics (min, max, final, by question number)
