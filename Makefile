PROJECT_NAME := vault-gatekeeper
package = github.com/packetloop/$(PROJECT_NAME)

.PHONY: test
test: dep env
	HOST=$(HOST) PORT=$(PORT) TF_ACC=$(TF_ACC) go test -race -cover -v ./...

.PHONY: dep
dep:
	$(eval GO111MODULE := on)
	go get github.com/tcnksm/ghr
	go get github.com/mitchellh/gox
	go mod tidy
	go mod vendor

.PHONY: env
env:
ifndef HOST
	$(error HOST is not set)
endif
ifndef PORT
	$(error PORT is not set)
endif

.PHONY: build
build: dep
	gox -output="./release/{{.Dir}}_{{.OS}}_{{.Arch}}" -os="linux windows darwin" -arch="amd64" .

.PHONY: create-tag
create-tag: next-tag
	 git fetch --tags packetloop
	 git tag -a v$(TAG) -m "v$(TAG)"
	 git push packetloop v$(TAG)

.PHONY: release
release:
	unset GO111MODULE && curl -sL https://git.io/goreleaser | bash

.PHONY: next-tag
next-tag:
ifndef TAG
	$(error TAG is not set)
endif
