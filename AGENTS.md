# Repository Guidelines

## Project Structure & Module Organization
- `backend/`: Ruby on Rails app (admin UI, API). Tests in `backend/spec/`; migrations in `backend/db/migrate/`; views in `backend/app/views/`; JS controllers in `backend/app/javascript/`.
- `frontend/`: Next.js (TypeScript + Tailwind). App routes under `frontend/src/app/`; components under `frontend/src/app/components/`; static assets in `frontend/public/`.
- Root ops files: `docker-compose.yml`, service `Dockerfile*`, Fly.io configs.

## Build, Test, and Development Commands
- Rails (local): `cd backend && bin/setup` (install gems, prepare DB), then `bin/rails s` (serve on `:3000`).
- Rails (tests): `cd backend && bundle exec rspec`.
- Rails (lint): `cd backend && bundle exec rubocop`.
- Next.js (dev): `cd frontend && npm run dev` (serves on `:3002`).
- Next.js (build/start): `cd frontend && npm run build && npm run start`.
- Docker (full stack): `docker compose up --build` (starts `backend`, `frontend`, `db`).

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
- Local env: `backend/.env.development` (used by Docker) and `frontend/.env` (see `frontend/.env.example`). Update CORS in `backend/config/initializers/cors.rb` when changing origins.

## Agent-Specific Notes
- Respect directory scopes above. When modifying many files, keep changes narrowly focused and run `rubocop` and `rspec` for backend, `npm run lint` for frontend before submitting.

