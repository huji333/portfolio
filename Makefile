# 開発環境（Mac ローカル + Traefik）の入口。本番系の操作は bin/ を参照
.PHONY: up down build logs ps migrate console urls

up: ## 開発環境を起動して URL を表示
	docker compose up -d
	@$(MAKE) --no-print-directory urls

down: ## 開発環境を停止
	docker compose down

build: ## イメージを再ビルド（依存や Dockerfile を変えたとき）
	docker compose build

logs: ## 全サービスのログを follow（Ctrl-C で抜けても環境は生きたまま）
	docker compose logs -f

ps: ## 起動状態を確認
	docker compose ps

migrate: ## DB マイグレーションを実行
	docker compose run --rm migrate

console: ## Rails コンソール
	docker compose exec backend rails console

urls:
	@echo "frontend:  http://portfolio.localhost"
	@echo "backend:   http://api.portfolio.localhost"
	@echo "traefik:   http://traefik.localhost  (ルーティング一覧)"
