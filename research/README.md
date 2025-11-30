# Enneagram Test - Research Phase

## Overview
Mobile-optimized Enneagram personality test with real-time confidence scoring.

## Research Artifacts

### 1. `enneagram-types.md`
Complete descriptions of all 9 Enneagram types including:
- Core motivations, fears, and desires
- Key personality traits
- Stress/growth directions
- Wing variants
- Centers of intelligence (Gut, Heart, Head)

### 2. `questions.csv`
70 carefully crafted questions with weighted scoring:
- Each question has weights for all 9 types (-3 to +3 scale)
- Covers all three centers (Gut, Heart, Head)
- 5-point Likert scale (Strongly Disagree to Strongly Agree)
- Balanced coverage across all personality aspects

### 3. `confidence-methodology.md`
Mathematical approach for real-time confidence calculation:
- Combines score separation, progress, and distribution
- Displays confidence percentage as user answers
- Color-coded confidence bands
- Optional early stopping at 95%+ confidence
- Handles edge cases (ties, flat distributions)

## App Architecture Plan

### Tech Stack
- **Backend:** Phoenix/Elixir
- **Database:** PostgreSQL (Railway)
- **Frontend:** Phoenix LiveView (mobile-first)
- **Deployment:** Railway

### Features
1. **Anonymous Testing** - No account required, just start
2. **Progressive Confidence** - See confidence build as you answer
3. **Real-time Scoring** - LiveView updates after each question
4. **Shareable Results** - Unique URL for each test result
5. **Mobile Optimized** - Touch-friendly, responsive design
6. **Result Storage** - All tests saved to DB with timestamps

### Database Schema
```
tests:
  - id (uuid)
  - started_at (timestamp)
  - completed_at (timestamp)
  - primary_type (1-9)
  - confidence (0-100)
  - scores (jsonb - all 9 type scores)
  - confidence_progression (jsonb - by question)

answers:
  - id
  - test_id (fk)
  - question_id (1-70)
  - answer_value (1-5)
  - answered_at (timestamp)
```

### User Flow
1. Land on homepage → "Start Test" button
2. Answer questions one at a time
3. See confidence update after each answer
4. After minimum 40 questions + 95% confidence = optional skip
5. Complete test → Redirect to results page
6. Results page shows:
   - Primary type with full description
   - Scores for all 9 types (bar chart)
   - Confidence progression graph
   - Shareable URL
7. Can restart test anytime

## Next Steps
1. Generate Phoenix app
2. Set up DB migrations
3. Create LiveView for test flow
4. Implement scoring engine
5. Design mobile UI
6. Deploy to Railway
7. Test on mobile devices
