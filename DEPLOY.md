# CD セットアップ手順（GHCR + Tailscale WIF）

main への push で GitHub Actions がイメージを GHCR に push し、Tailscale 経由で
mr2 の `bin/deploy` を実行する。**静的な長期 credential はどこにも置かない**：

| 経路 | 認証 |
|---|---|
| Actions → GHCR | ジョブ毎に自動発行される `GITHUB_TOKEN`（短命） |
| Actions → tailnet | GitHub OIDC → Tailscale [workload identity federation](https://tailscale.com/kb/1581/workload-identity-federation)（短命） |
| runner → mr2 SSH | Tailscale SSH（鍵レス、ACL で制御） |
| mr2 → GHCR pull | 匿名（public package） |

デプロイフロー: `build/push (GHCR)` → `tailnet 参加` → `ssh mr2 bin/deploy <sha>`
→ `compose pull` → `DB バックアップ` → `migrate` → `up -d` → `healthcheck`（失敗で job 赤）

## 初回セットアップ

### 1. mr2 の Tailscale 設定（#237 で導入済み、タグ付けのみ追加）

tailscaled + Tailscale SSH は 2026-07-03 に導入済み。CD 用に必要な残作業:

```bash
# mr2 上で: WIF に 1.90.1 以上が必要（古ければ apt upgrade）
tailscale version

# tag:prod を広告（ACL の dst 指定に使う。--ssh は既存設定の維持で必要）
sudo tailscale up --ssh --advertise-tags=tag:prod
```

- Tailscale SSH は port 22 を横取りするため、鍵ベース SSH は実 sshd に届かない（既知）
- CD に必要なのは mr2 のみ（pve は不要）

### 2. Tailscale ACL（管理画面 → Access Controls）

```jsonc
{
  "tagOwners": {
    "tag:ci":   ["autogroup:admin"],
    "tag:prod": ["autogroup:admin"],
  },
  "grants": [
    // 人間のデバイスは全許可（デフォルトの src "*" から変更。
    // "*" のままだと tag:ci ノードが pve 等タネット内全部に届いてしまう）
    {"src": ["autogroup:member"], "dst": ["*"], "ip": ["*"]},
    // CI ランナーは mr2 の SSH にのみ到達可（Tailscale SSH でも tcp:22 の grant が必要）
    {"src": ["tag:ci"], "dst": ["tag:prod"], "ip": ["tcp:22"]},
  ],
  "ssh": [
    // 既存: 自分のタグなしデバイスへの SSH（デフォルトルール、残す）
    {"action": "check", "src": ["autogroup:member"], "dst": ["autogroup:self"],
     "users": ["autogroup:nonroot", "root"]},
    // 罠: mr2 は tag:prod を付けると autogroup:self から外れるため、
    // このルールがないと人間の ssh mr2 が壊れる
    {"action": "check", "src": ["autogroup:member"], "dst": ["tag:prod"],
     "users": ["autogroup:nonroot", "root"]},
    // 鍵レス SSH: tag:ci ノードから mr2 に huji333 としてのみ入れる。
    // CI は非対話なので必ず "accept"（"check" だとブラウザ承認待ちで詰まる）
    {"action": "accept", "src": ["tag:ci"], "dst": ["tag:prod"], "users": ["huji333"]},
  ],
  "tests": [
    {"src": "tag:ci", "accept": ["tag:prod:22"]},
  ],
}
```

**適用順序**: ACL を保存してから mr2 で `tailscale up --advertise-tags=tag:prod` を実行
（tagOwners 未定義のまま advertise するとエラー）。副作用: tag 付け後の mr2 は src として
許可する grant がないためタネット内の他ノードへ自発接続できない（外向き通信は無影響）。

### 3. Workload identity federation（管理画面）

[KB: workload-identity-federation](https://tailscale.com/kb/1581/workload-identity-federation) に従い
federated identity client を作成:

- **Issuer**: `https://token.actions.githubusercontent.com`
- **Subject の条件**: `repo:huji333/portfolio:ref:refs/heads/main`
  （main の push / main 上での手動 dispatch だけがトークンを取得できる）
- **Audience**: 任意の文字列（例: `portfolio-deploy`）
- **Scope**: `auth_keys` (write)、タグは `tag:ci`

発行された client ID と audience を GitHub repo の **Variables**（Settings →
Secrets and variables → Actions → Variables）に登録:

- `TS_FEDERATED_CLIENT_ID`
- `TS_AUDIENCE`

どちらも秘密情報ではないので Variables でよい（Secrets に入れる長期トークンは存在しない）。

### 4. GHCR パッケージを public にする

初回の Deploy 実行（build まで成功し deploy で失敗してよい）後、
`ghcr.io/huji333/portfolio-backend` / `portfolio-frontend` の package settings で
**Visibility: Public** に変更（public repo のビルド成果物なので秘匿する意味はない）。
これで mr2 は `docker login` なしで pull できる。

### 5. mr2 側の前提確認

```bash
# ~/portfolio の remote が匿名 pull できる HTTPS であること（bin/deploy が git pull する）
git -C ~/portfolio remote set-url origin https://github.com/huji333/portfolio.git
```

- `.env` の `IMAGE_TAG` は `bin/deploy` が自動で追記・更新する（手動編集不要）
- GitHub 側の branch protection（main への直 push 禁止 + CI 必須）を有効にすること。
  「main に push できる = mr2 に SSH できる」構成なので、これが実質の防壁

## 運用

- **通常デプロイ**: PR を main にマージするだけ（backend/frontend/compose に差分があるとき発火）
- **ロールバック**: Actions → Deploy → Run workflow で `image_tag` に過去の commit SHA を指定
  （build はスキップされ、そのイメージを再デプロイ。compose ファイルは最新 main のままな点に注意）
- **緊急時のローカルビルド**: mr2 上で従来通り
  `docker compose -f docker-compose.prod.yml up -d --build`（`build:` は残してある）

## セキュリティ上の判断メモ（2026-07）

- push 型（Actions → Tailscale SSH）を選択。pull 型（mr2 が GHCR をポーリング）は
  GitHub→自宅の経路が構成上消える分強いが、月2回程度のデプロイ頻度では
  Actions 上で成否が見える運用性と migrate の順序制御を優先した
- GHA の主リスクは「secrets の長期トークンを供給網攻撃で抜かれる」パターン
  （2025-03 tj-actions 事件等）。本構成は抜かれる長期トークンが存在せず、
  action は全て commit SHA でピン留めしている
- fork PR には OIDC トークンも secrets も渡らないため public repo でも安全
  （deploy は `push: main` と手動 dispatch のみで発火）
- **この repo に self-hosted runner を置かないこと**（fork PR のコードが
  自宅 LAN で実行されうる唯一の明確な NG 構成）
