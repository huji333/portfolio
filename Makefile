# 開発環境（Mac ローカル + Traefik）の入口。本番系の操作は bin/ を参照
.PHONY: up urls

up: ## 開発環境を起動して URL を表示
	docker compose up -d
	@$(MAKE) --no-print-directory urls

urls:
	@echo "frontend:  http://portfolio.localhost"
	@echo "backend:   http://api.portfolio.localhost"
	@echo "traefik:   http://traefik.localhost  (ルーティング一覧)"
