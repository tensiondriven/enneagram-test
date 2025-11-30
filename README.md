# Enneagram Test

A mobile-optimized Enneagram personality test with real-time confidence tracking built with Phoenix LiveView.

## Features

- **70 carefully crafted questions** covering all 9 Enneagram types
- **Real-time confidence scoring** - watch your type emerge as you answer
- **Mobile-first design** - optimized for touch and small screens
- **Anonymous testing** - no account required
- **Shareable results** - unique URL for each test result
- **Progressive confidence display** - see top 3 types and confidence percentage
- **Optional early completion** - skip to results when confidence reaches 95%+

## Local Development

### Prerequisites

- Elixir 1.18+
- PostgreSQL
- Node.js (for asset compilation)

### Setup

```bash
# Install dependencies
mix deps.get
npm install --prefix assets

# Create and migrate database
mix ecto.create
mix ecto.migrate

# Load questions into database
mix run priv/repo/seeds.exs

# Start Phoenix server
mix phx.server
```

Visit `http://localhost:4000` in your browser.

## Railway Deployment

### One-Click Deploy

1. Click "Deploy on Railway" or manually create a new project
2. Add a PostgreSQL database service
3. Set environment variables:
   - `DATABASE_URL` (automatically set by Railway PostgreSQL)
   - `SECRET_KEY_BASE` (generate with `mix phx.gen.secret`)
   - `PHX_HOST` (your Railway domain)
   - `PORT` (automatically set by Railway, usually 3000)

### After Deployment

Run migrations and seed data:

```bash
# In Railway's shell or via railway CLI
./bin/migrate
```

The app will be available at your Railway-provided URL.

## Tech Stack

- **Backend:** Elixir + Phoenix Framework
- **Frontend:** Phoenix LiveView + TailwindCSS
- **Database:** PostgreSQL
- **Deployment:** Railway (Docker)

## Project Structure

```
lib/enneagram_web/
├── question.ex          # Question schema
├── test.ex             # Test session schema
├── answer.ex           # Answer schema
├── assessment.ex       # Context for managing tests
└── scoring.ex          # Scoring engine with confidence calculation

lib/enneagram_web_web/live/
├── home_live.ex        # Homepage
├── test_live.ex        # Test flow with real-time confidence
└── results_live.ex     # Results page with shareable URL

research/
├── questions.csv       # 70 questions with type weights
├── enneagram-types.md  # Full type descriptions
└── confidence-methodology.md  # Scoring algorithm documentation
```

## Research & Methodology

See the `research/` directory for:
- Complete Enneagram type descriptions
- Question design and weighting methodology
- Confidence interval calculation algorithm
- Type characteristics and motivations
