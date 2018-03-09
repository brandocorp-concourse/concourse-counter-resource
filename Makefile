VERSION="latest"
IMAGE="concourse-counter-resource"

all: test

check:
	(docker --version 2>&1 >/dev/null) || exit "Docker must be installed, and accessible via PATH"

image: check
	docker build $(PWD) -f Dockerfile -t brandocorp/$(IMAGE):$(VERSION)

test: check image
	test/local.sh

publish: image test
	docker push brandocorp/$(IMAGE):$(VERSION)
