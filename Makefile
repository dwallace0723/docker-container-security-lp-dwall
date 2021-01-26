default: build

lint-dockerfile:
	@echo "Linting Dockerfile..."
	@docker run --rm -i -v $(PWD)/.hadolint.yaml:/.hadolint.yaml hadolint/hadolint < $(PWD)/Dockerfile
	
build: lint-dockerfile
	@echo "Building Hugo Builder container..."
	@docker build -t lp/hugo-builder .
	@echo "Hugo Builder container built!"
	@docker images lp/hugo-builder

hugo-build: build
	@echo "Building the Hugo Site..."
	@docker run --rm -v $(PWD)/orgdocs:/src lp/hugo-builder hugo

hugo-serve: hugo-build
	@echo "Serving the Hugo Site..."
	@docker run --rm -d -p 1313:1313 -v $(PWD)/orgdocs:/src lp/hugo-builder hugo server -w --bind=0.0.0.0
	
.PHONY: build hugo-build hugo-serve lint-dockerfile
