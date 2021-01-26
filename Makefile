default: all

all: build lint

build:
    @echo "Building Hugo Builder container..."
    @docker build -t lp/hugo-builder .
    @echo "Hugo Builder container built!"
    @docker images lp/hugo-builder

lint:
    @echo "Linting the Hugo Builder container..."
    @docker run --rm -i hadolint/hadolint:v1.17.5-alpine \
        hadolint --ignore DL3018 - < Dockerfile
    @echo "Linting completed!"

#hugo_build:
#   @echo "Building the OrgDocs Hugo site..."
#   @docker run --rm -it -v $(PWD)/orgdocs:/src -u hugo lp/hugo-builder hugo
#   @echo "OrgDocs Hugo site built!"

hugo_build:
    @echo "Building the OrgDocs Hugo site..."
    @docker run --rm -it \
        --mount type=bind,src=${PWD}/orgdocs,dst=/src -u hugo \
        lp/hugo-builder hugo
    @echo "OrgDocs Hugo site built!"

#start_server:
#   @echo "Serving the OrgDocs Hugo site..."
#   @docker run -d --rm -it -v $(PWD)/orgdocs:/src -p 1313:1313 -u hugo \
#       --name hugo_server lp/hugo-builder hugo server -w --bind=0.0.0.0
#   @echo "OrgDocs Hugo site being served!"
#   @docker ps --filter name=hugo_server

start_server:
    @echo "Serving the OrgDocs Hugo site..."
    @docker run -d --rm -it --name hugo_server \
        --mount type=bind,src=${PWD}/orgdocs,dst=/src -u hugo \
        -p 1313:1313 lp/hugo-builder hugo server -w --bind=0.0.0.0
    @echo "OrgDocs Hugo site being served!"
    @docker ps --filter name=hugo_server

check_health:
    @echo "Checking the health of the Hugo Server..."
    @docker inspect --format='{{json .State.Health}}' hugo_server

    
stop_server:
    @echo "Stopping the OrgDocs Hugo site..."
    @docker stop hugo_server
    @echo "OrgDocs Hugo site stopped!"

inspect_labels:
    @echo "Inspecting Hugo Server Container labels..."
    @echo "maintainer set to..."
    @docker inspect --format '{{ index .Config.Labels "maintainer" }}' \
        hugo_server
    @echo "Labels inspected!"

.PHONY: build lint hugo_build start_server check_health stop_server \
  inspect_labels