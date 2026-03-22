# 自宅サーバー移行 — 残タスク

## 対応済み

- ~~**セキュリティヘッダー**~~ — Cloudflare で HSTS 等を管理
- ~~**PostgreSQLバックアップ戦略**~~ — `bin/backup-db` (pg_dump + gzip + ローテーション) (#56)
- ~~**Docker Composeネットワーク分離**~~ — `backend` (internal) / `frontend` ネットワークで DB を隔離 (#58)
- ~~**初期セットアップスクリプト**~~ — `bin/setup-prod` で `.env` / 秘密鍵を自動生成 (#60)
- ~~**外部公開**~~ — Cloudflare Tunnel で Caddy を置き換え（ポート転送・DDNS 不要）

## デプロイチェックリスト

### Proxmox VM セットアップ
- [x] VM 作成（Ubuntu Server 24.04、メモリ 4GB、ディスク 32GB）
- [x] Docker & Docker Compose インストール
- [x] リポジトリを clone

### アプリケーション起動
- [x] `.env` を作成（`.env.prod.sample` をコピー＆編集）
- [x] `docker compose -f docker-compose.prod.yml --profile migrate run --rm migrate`
- [ ] `docker compose -f docker-compose.prod.yml up -d --build`

### Cloudflare Tunnel
- [ ] Cloudflare にドメイン追加 + ネームサーバー変更
- [ ] Tunnel 作成 + CLOUDFLARE_TUNNEL_TOKEN を `.env` に設定
- [ ] Public Hostname 設定: `kakemu.work` → `http://frontend:3000`
- [ ] Public Hostname 設定: `api.kakemu.work` → `http://backend:3000`

### 動作確認
- [ ] HTTPS アクセス確認
- [ ] SSR が正常動作するか確認（ページソースに画像データが含まれるか）
- [ ] 管理画面ログイン確認

### 運用
- [ ] DB バックアップの cron 設定 (`0 3 * * * cd /path/to/portfolio && bash bin/backup-db`)
- [ ] Cloudflare セキュリティヘッダー設定（HSTS, X-Frame-Options 等）
