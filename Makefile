
test:
	docker compose run --rm test_runner

test-watch:
	docker compose run --rm test_watcher

dev:
	bash scripts/build-deploy-start.sh

prod:
	bash scripts/build-prod.sh

prettier:
	docker compose run --rm build npm run prettier

prettier-fix:
	docker compose run --rm build npm run prettier:fix
