# Repository Guidelines

## Project Structure

- `backend/` — Rails 7.2 API + admin UI (Ruby 3.3.5)
- `frontend/` — Next.js 15 + React 19 (TypeScript, Tailwind, Yarn 4)
- `docker-compose.yml` / `docker-compose.prod.yml` — 開発・本番環境
- `.github/workflows/` — CI (`backend.yml`, `frontend.yml`)

## Commands

### Development
```bash
docker compose up -d        # 全サービス起動
docker compose down          # 停止
```

### Backend (`backend/` 内)
```bash
bundle exec rspec            # テスト
bundle exec rubocop          # lint
```

### Frontend (`frontend/` 内, Yarn 4 / corepack)
```bash
yarn dev                     # 開発サーバー
yarn build                   # ビルド
yarn lint                    # ESLint
yarn tsc --noEmit            # 型チェック
```

## Coding Style

- **Ruby**: 2-space indent, RuboCop準拠。モデル単数形、コントローラ複数形。
- **TypeScript/React**: 2-space indent。コンポーネントPascalCase、hooks camelCase。
- **CSS**: Tailwind utility-first。

## Testing

- Backend: RSpec (`backend/spec/`)。ファクトリは `backend/spec/factories/`。
- Frontend: テストフレームワーク未導入。

## Commit & PR

- コミット: 簡潔な命令形 (50文字以内)。例: `feat(frontend): add ImageGrid modal`
- PR: スコープ・要約・関連issue・テスト手順を記載。DB migrationやENV変更があれば明記。

## Security

- シークレットをコミットしない。Rails credentialsは `bin/rails credentials:edit` で編集。
- 環境変数: `backend/.env.development`, `frontend/.env.local`。CORS設定は `backend/config/initializers/cors.rb`。
