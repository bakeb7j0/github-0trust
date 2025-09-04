
CONTRIB_DIR ?= $(shell if [ -d third_party/github-0trust ]; then echo third_party/github-0trust; \
                 elif [ -d .tooling/github-0trust ]; then echo .tooling/github-0trust; else echo third_party/github-0trust; fi)
SCRIPTS := $(CONTRIB_DIR)/scripts
DEFAULT_BRANCH ?= main
CONTRIB_PREFIX ?= contribute
PR_TARGET_BRANCH ?= main
PUSH_PR ?= false
MIRROR_REMOTE_NAME ?= gitlab
BARE_REPO_PATH ?= /srv/git/repo.git
.PHONY: verify demo apply setup-mirror harden
verify:
	@test -d $(CONTRIB_DIR) || (echo 'Missing $(CONTRIB_DIR)'; exit 1)
	@$(SCRIPTS)/verify-env.sh
demo: verify
	@echo '[demo] applying examples/demo.patch'
	@BARE_REPO_PATH=$$(git rev-parse --git-dir) DEFAULT_BRANCH='$(DEFAULT_BRANCH)' CONTRIB_PREFIX='$(CONTRIB_PREFIX)' PUSH_PR='$(PUSH_PR)' PR_TARGET_BRANCH='$(PR_TARGET_BRANCH)' $(SCRIPTS)/contribute-commit examples/demo.patch demo
apply: verify
	@[ -n '$(PATCH)' ] || (echo 'Usage: make apply PATCH=path/to.patch [TOPIC=name]'; exit 2)
	@BARE_REPO_PATH=$$(git rev-parse --git-dir) DEFAULT_BRANCH='$(DEFAULT_BRANCH)' CONTRIB_PREFIX='$(CONTRIB_PREFIX)' PUSH_PR='$(PUSH_PR)' PR_TARGET_BRANCH='$(PR_TARGET_BRANCH)' $(SCRIPTS)/contribute-commit '$(PATCH)' '$(TOPIC)'
setup-mirror: verify
	@[ -n '$(GIT_REMOTE_URI)' ] || (echo 'Usage: make setup-mirror GIT_REMOTE_URI=ssh://...'; exit 2)
	@BARE_REPO_PATH='$(BARE_REPO_PATH)' DEFAULT_BRANCH='$(DEFAULT_BRANCH)' MIRROR_REMOTE_NAME='$(MIRROR_REMOTE_NAME)' GIT_REMOTE_URI='$(GIT_REMOTE_URI)' $(SCRIPTS)/setup_mirror.sh
harden:
	@[ -n '$(BARE_REPO_PATH)' ] || (echo 'Usage: make harden BARE_REPO_PATH=/srv/git/repo.git'; exit 2)
	@BARE_REPO_PATH='$(BARE_REPO_PATH)' $(SCRIPTS)/harden.sh
