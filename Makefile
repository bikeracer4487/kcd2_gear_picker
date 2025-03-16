check: test prettier

test:
	docker compose run --rm test_runner

test-watch:
	docker compose run --rm test_watcher

dev:
	bash scripts/build-deploy-start.sh

dev-kcd1:
	bash scripts/build-deploy-start.sh kcd1

dev-random:
	bash scripts/build-deploy-start.sh random

prod:
	bash scripts/build-prod.sh main
	make prod-random
	make prod-helmet_only
	make prod-ranged

prod-random:
	bash scripts/build-prod.sh random
prod-helmet_only:
	bash scripts/build-prod.sh helmet_only
prod-ranged:
	bash scripts/build-prod.sh ranged

prettier:
	docker compose run --rm ci-cd npm run prettier

prettier-fix:
	docker compose run --rm ci-cd npm run prettier:fix

docs:
	docker compose run --rm ci-cd npm run generate_readme
