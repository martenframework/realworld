init:
	@printf "\n\n${YELLOW}---------------- Initialization ---${RESET} ${GREEN}Crystal dependencies${RESET}\n\n"

	shards install

	@printf "\n\n${YELLOW}---------------- Done.${RESET}\n\n"


# DEVELOPMENT
# ~~~~~~~~~~~
# The following rules can be used during development in order to launch development server, generate
# locales, etc.
# --------------------------------------------------------------------------------------------------

.PHONY: s server
## Alias of "server".
s: server
## Launch a development server.
server:
	bin/marten serve


# QUALITY ASSURANCE
# ~~~~~~~~~~~~~~~~~
# The following rules can be used to check code quality and perform sanity checks.
# --------------------------------------------------------------------------------------------------

.PHONY: qa qa_crystal qa_js
## Trigger all quality assurance checks.
qa: qa_crystal qa_js
## Trigger Crystal quality assurance checks.
qa_crystal: lint_crystal
## Trigger Javascript quality assurance checks.
qa_js: lint_js

.PHONY: format_crystal
## Perform and apply crystal formatting.
format_crystal:
	crystal tool format --exclude docs

.PHONY: lint lint_crystal lint_js
## Trigger code quality checks.
lint: lint_crystal lint_js
## Trigger code Crystal quality checks.
lint_crystal:
	crystal tool format --exclude docs --check
	bin/ameba
## Trigger Javascript code quality checks (eslint).
lint_js:
	npm run lint

# TESTING
# ~~~~~~~
# The following rules can be used to trigger tests execution and produce coverage reports.
# --------------------------------------------------------------------------------------------------

.PHONY: t tests
## Alias of "tests".
t: tests
## Run all the test suites.
tests: tests_crystal
## Run the Crystal test suite.
tests_crystal:
	crystal spec


# MAKEFILE HELPERS
# ~~~~~~~~~~~~~~~~
# The following rules can be used to list available commands and to display help messages.
# --------------------------------------------------------------------------------------------------

# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: help
## Print Makefile help.
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<action>${RESET}'
	@echo ''
	@echo 'Actions:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)-30s${RESET}\t${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST) | sort -t'|' -sk1,1
