# Fly.io → 自宅サーバー（オンプレ）移行ノート

## 現状アーキテクチャ

```
[Fly.io]
  Frontend (Next.js 15) --- huji333-portfolio-frontend (nrt, min 0台)
  Backend  (Rails 7.2)  --- huji333-portfolio-backend  (nrt, min 1台)
  画像: S3 + CloudFront

[オンプレ用 (docker-compose.prod.yml)]
  Caddy (TLS終端) → Frontend / Backend / PostgreSQL
  画像: S3 + CloudFront (変更なし)
```

---

## クリティカル（起動しない or 動作しない）

### 1. `force_ssl` による無限リダイレクトループ

**ファイル:** `backend/config/environments/production.rb:52`

```ruby
config.force_ssl = true
```

Caddy が TLS を終端するため、Caddy → Rails 間は HTTP。Rails は「HTTPだからHTTPSにリダイレクトしろ」を返し続け、**無限ループ**になる。

**修正:** `config.assume_ssl = true` を有効化する（49行目のコメントを外す）。これにより Rails は「自分の前に TLS 終端プロキシがいる」と認識し、リダイレクトせず正常動作する。

```ruby
config.assume_ssl = true   # ← コメント解除
config.force_ssl = true    # ← これは残してOK（HSTSヘッダ + secure cookieのため）
```

### 2. フロントエンド SSR の API 接続先が未設定

**ファイル:** `docker-compose.prod.yml:25-37` / `frontend/src/utils/api.ts`

Next.js のサーバーサイドレンダリング (SSR) 時、`API_BASE_URL` 環境変数で内部ネットワーク経由（`http://backend:3000/api`）にアクセスする設計になっている。しかし `docker-compose.prod.yml` の frontend サービスには `API_BASE_URL` が設定されていない。

現状の `getApiBaseUrl()` のフォールバック順:
1. `API_BASE_URL` → **未設定**
2. `NEXT_PUBLIC_API_BASE_URL` → ビルド時に焼き込まれた外部URL（`https://api.yourdomain.com/api`）
3. `http://localhost:3000/api` → フォールバック

SSR時にコンテナ内から外部ドメインにアクセスする形になる。自宅サーバーの場合、ヘアピンNAT非対応のルーターだと**SSRが失敗**する。

**修正:** `docker-compose.prod.yml` の frontend サービスに runtime 環境変数を追加:

```yaml
frontend:
  environment:
    NODE_ENV: production
    API_BASE_URL: http://backend:3000/api  # ← 追加
```

### 3. Caddy にセキュリティヘッダーがない

**ファイル:** `Caddyfile.example`

現状は最小限の reverse_proxy のみ。Fly.io ではエッジで処理されていたセキュリティヘッダーがオンプレでは欠落する。

**修正案:**

```caddy
yourdomain.com {
  header {
    X-Content-Type-Options "nosniff"
    X-Frame-Options "DENY"
    Referrer-Policy "strict-origin-when-cross-origin"
    -Server
  }
  reverse_proxy frontend:3000
}

api.yourdomain.com {
  header {
    X-Content-Type-Options "nosniff"
    -Server
  }
  reverse_proxy backend:3000
}
```

---

## 重要（本番運用で問題になる）

### 4. PostgreSQL のバックアップ戦略がない

**ファイル:** `docker-compose.prod.yml`

Fly.io では Fly Postgres にスナップショット機能があるが、オンプレでは自前でバックアップが必要。Docker volume (`db_data`) が壊れるとデータ全損。

**対応案:**
- cron + `pg_dump` でローカルバックアップ
- S3 等へのオフサイトバックアップ
- 例: `docker compose -f docker-compose.prod.yml exec db pg_dump -U backend backend_production | gzip > backup_$(date +%Y%m%d).sql.gz`

### 5. DB パスワードのデフォルトが弱い

**ファイル:** `.env.prod.sample:5`

```
BACKEND_DATABASE_PASSWORD=your_strong_db_password_here
```

プレースホルダだが、実運用時に弱いパスワードが使われるリスク。DB は Docker 内部ネットワークのみだが、念のため `openssl rand -base64 32` 等で生成を推奨。

### 6. CI/CD が Fly.io 専用のまま

**ファイル:** `.github/workflows/fly.yml`

`main` push 時に Fly.io にデプロイする workflow がそのまま残っている。オンプレ移行後は:
- この workflow を無効化 or 削除
- 必要に応じて SSH + docker compose でのデプロイ workflow に置き換え
- または手動デプロイ（`docker compose -f docker-compose.prod.yml up -d --build`）

### 7. ログの永続化がない

**ファイル:** `docker-compose.prod.yml`

Rails / Next.js のログが STDOUT に出力されるが、コンテナ再起動で消える。Fly.io では Fly のログ基盤で保持されていたが、オンプレでは対策が必要。

**対応案:**
- Docker のログドライバ設定（`json-file` + ローテーション）
- または logging サービス

```yaml
backend:
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
```

---

## 推奨（あると良い改善）

### ~~8. ヘルスチェックがサービスに未設定~~ → 対応済み

backend に healthcheck を追加し、Caddy が `service_healthy` を待つように変更済み。

### ~~9. frontend Dockerfile の Fly.io ラベル~~ → 対応済み

`LABEL fly_launch_runtime="Next.js"` を削除済み。

### ~~10. Host Authorization (Rails)~~ → 対応済み

`RAILS_ALLOWED_HOSTS` 環境変数で設定可能にした。`.env.prod` に `RAILS_ALLOWED_HOSTS=api.yourdomain.com` を設定すること。

### 11. docker-compose.prod.yml の DB ポート露出

現状 DB はポートを外部に expose していない（良い設計）。ただし明示的にネットワークを分離するとより安全:

```yaml
networks:
  internal:
    driver: bridge
  external:
    driver: bridge

services:
  caddy:
    networks: [external, internal]
  backend:
    networks: [internal]
  frontend:
    networks: [internal]
  db:
    networks: [internal]
```

### 12. SECRET_KEY_BASE の自動生成

`bin/docker-entrypoint` で `db:prepare` は実行するが、`SECRET_KEY_BASE` が未設定だと Rails が起動しない。`.env.prod.sample` にコメントで生成方法が書いてあるが、READMEやセットアップスクリプトがあると初期構築が楽になる。

---

## 移行チェックリスト

- [ ] `.env.prod` を作成（`.env.prod.sample` をコピー＆編集）
- [ ] `Caddyfile` を作成（`Caddyfile.example` をコピー＆ドメイン名を置換）
- [x] `config.assume_ssl = true` を有効化
- [x] `docker-compose.prod.yml` で frontend に `API_BASE_URL` を追加
- [ ] ルーターのポート転送設定（80, 443）
- [ ] DDNS 設定（固定IPがない場合）
- [ ] DB バックアップの cron 設定
- [x] ログローテーション設定
- [ ] `.github/workflows/fly.yml` の無効化
- [ ] `docker compose -f docker-compose.prod.yml up -d --build` で起動確認
- [ ] HTTPS アクセス確認
- [ ] SSR が正常動作するか確認（ページソースに画像データが含まれるか）
- [ ] DNS を切り替え（Fly.io → 自宅サーバーIP）
