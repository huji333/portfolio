# Repository Guidelines

## Project Structure & Module Organization

- `backend/`: Ruby on Rails app (admin UI, API).
    - `backend/app/controllers/`: Rails controllers.
    - `backend/app/models/`: Rails models.
    - `backend/app/views/`: Rails views.
    - `backend/app/javascript/`: JavaScript controllers for Rails.
    - `backend/db/migrate/`: Database migrations.
    - `backend/spec/`: RSpec tests.
- `frontend/`: Next.js (TypeScript + Tailwind).
    - `frontend/src/app/`: Next.js app routes.
    - `frontend/src/ui/`: React components.
    - `frontend/src/hooks/`: Custom React hooks.
    - `frontend/src/utils/`: Utility functions.
    - `frontend/public/`: Static assets.
- Root ops files:
    - `docker-compose.yml`: Docker Compose configuration.
    - `backend/Dockerfile`, `frontend/Dockerfile`: Dockerfiles for backend and frontend services.
    - `fly.yml` (root), `backend/fly.toml`, `frontend/fly.toml`: Fly.io deployment configurations.

## Build, Test, and Development Commands

- Using docker compose for local development.
    - Start services: `docker compose up -d`
    - Stop services: `docker compose down`
    - Build services: `docker compose build`
- Backend (inside `backend` container):
    - Run tests: `bundle exec rspec`
    - Run RuboCop: `bundle exec rubocop`
- Frontend (inside `frontend` container):
    - Start development server: `npm run dev`
    - Build for production: `npm run build`
    - Run ESLint: `npm run lint`

## Coding Style & Naming Conventions

- Ruby: 2-space indent, follow RuboCop (`backend/.rubocop.yml`). Models singular (`Image`), controllers plural (`ImagesController`). Migrations use snake_case: `20241019_create_images.rb`.
- TypeScript/React: 2-space indent. Components PascalCase (`ImageGrid.tsx`), hooks camelCase (`useImageFilter.ts`). Pages live under `src/app/.../page.tsx`.
- CSS: Tailwind utility-first in `frontend/src/app/globals.css` and component classes.

## Testing Guidelines
- Framework: RSpec in `backend/spec/` (model, request, and system specs). Name tests `*_spec.rb` (e.g., `spec/models/image_spec.rb`). Run with `bundle exec rspec`.
- Factories live in `backend/spec/factories/`.
- Frontend: no test framework configured; if adding, prefer Vitest or Jest + Testing Library with files `*.test.tsx` near sources.

## Commit & Pull Request Guidelines
- Commits: concise, imperative subject (50 chars max), optional body with rationale. Example: `feat(frontend): add ImageGrid modal`.
- PRs: include scope/summary, linked issues, steps to test, and screenshots for UI changes. Call out DB migrations and any ENV changes (e.g., `FRONTEND_ORIGIN`).

## Security & Configuration Tips
- Do not commit secrets. Rails credentials live in `backend/config/credentials.yml.enc` (edit via `bin/rails credentials:edit`).
- Local env: `backend/.env.development` (used by Docker), `frontend/.env.local` (local environment variables), and `frontend/.env.production` (production environment variables). Update CORS in `backend/config/initializers/cors.rb` when changing origins.

## Agent-Specific Notes
- Respect directory scopes above. When modifying many files, keep changes narrowly focused and run `rubocop` and `rspec` for backend, `npm run lint` for frontend before submitting.
