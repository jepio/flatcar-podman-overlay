TAG = dev:latest
FLATCAR_VERSION = 3200.0.0

container:
	docker build -t $(TAG) --build-arg FLATCAR_VERSION=$(FLATCAR_VERSION) .
