# 自宅サーバー移行 — 残タスク

## 未対応

- **Caddyセキュリティヘッダー追加** — `Caddyfile.example` に `X-Content-Type-Options`, `X-Frame-Options` 等を追加 (#58 のネットワーク分離と合わせて対応)
- **PostgreSQLバックアップ戦略** — cron + `pg_dump` + S3オフサイト (#56)
- **Docker Composeネットワーク分離** — DB を internal network に隔離 (#58)
- **初期セットアップスクリプト** — `.env.prod` / `Caddyfile` / `SECRET_KEY_BASE` 生成の自動化 (#60)

## デプロイチェックリスト

- [ ] `.env.prod` を作成（`.env.prod.sample` をコピー＆編集）
- [ ] `Caddyfile` を作成（`Caddyfile.example` をコピー＆ドメイン名を置換）
- [ ] ルーターのポート転送設定（80, 443）
- [ ] DDNS 設定（固定IPがない場合）
- [ ] DB バックアップの cron 設定
- [ ] `docker compose -f docker-compose.prod.yml up -d --build` で起動確認
- [ ] HTTPS アクセス確認
- [ ] SSR が正常動作するか確認（ページソースに画像データが含まれるか）
- [ ] DNS を切り替え（自宅サーバーIP）
