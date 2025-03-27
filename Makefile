check: test prettier

test:
	docker compose run --rm --entrypoint "" test_runner sh -c "busted --verbose /data"

## Pattern Usage: make test-watch pattern=OnTalkEvent_HelmetOnly
test-watch:
	pattern_arg=$(if $(pattern),--pattern=$(pattern)) && \
	docker compose run --rm --entrypoint "" test_watcher \
		sh -c "find /data -type f | entr -c busted $$pattern_arg --verbose /data"

test-coverage:
	docker compose run --rm --entrypoint "" test_runner \
        sh -c "busted --verbose --coverage /data \
          && luacov \
          && tail -n 1 luacov.report.out | awk '{print \"percentage=\" \$$NF}' | sed 's/%//' > /data/coverage.env \
          && luacov -r html \
          && mv luacov.report.out luacov.report.html"

.PHONY: dev
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
	docker compose run --rm nodejs npm run prettier

prettier-fix:
	docker compose run --rm nodejs npm run prettier:fix

docs:
	docker compose run --rm dev npm run generate_readme
