# 自宅サーバー移行 — 残タスク

## 対応済み

- ~~**Caddyセキュリティヘッダー追加**~~ — HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Permissions-Policy (#58)
- ~~**PostgreSQLバックアップ戦略**~~ — `bin/backup-db` (pg_dump + gzip + ローテーション) (#56)
- ~~**Docker Composeネットワーク分離**~~ — `backend` (internal) / `frontend` ネットワークで DB を隔離 (#58)
- ~~**初期セットアップスクリプト**~~ — `bin/setup-prod` で `.env` / `Caddyfile` / 秘密鍵を自動生成 (#60)

## デプロイチェックリスト

### Proxmox VM セットアップ
- [ ] VM 作成（Ubuntu Server 24.04 推奨、メモリ 2GB+、ディスク 20GB+）
- [ ] Docker & Docker Compose インストール
- [ ] リポジトリを clone

### アプリケーション起動
- [ ] `bash bin/setup-prod` で `.env` / `Caddyfile` を生成
- [ ] `docker compose -f docker-compose.prod.yml --profile migrate run --rm migrate`
- [ ] `docker compose -f docker-compose.prod.yml up -d --build`

### ネットワーク
- [ ] ルーターのポート転送設定（80, 443 → VM の IP）
- [ ] DDNS 設定（固定IPがない場合）
- [ ] DNS の A レコードを自宅 IP に変更

### 動作確認
- [ ] HTTPS アクセス確認
- [ ] SSR が正常動作するか確認（ページソースに画像データが含まれるか）
- [ ] 管理画面ログイン確認

### 運用
- [ ] DB バックアップの cron 設定 (`0 3 * * * cd /path/to/portfolio && bash bin/backup-db`)
