TAG = dev:latest
FLATCAR_VERSION = 3200.0.0
OVERLAY_DIR = /var/lib/portage/podman-overlay

snapd.raw: container
	docker run -it --rm -v $(PWD):/out $(TAG)

.PHONY: container
container:
	docker build -t $(TAG) --build-arg FLATCAR_VERSION=$(FLATCAR_VERSION) .

