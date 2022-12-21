IMAGE_NAME = "didstopia/klipperscreen-remote"

.PHONY: build run test

build:
	@docker build -t $(IMAGE_NAME) .

run: build
	@docker run -it --rm --name klipperscreen-remote $(IMAGE_NAME)

test: build
	@docker run -it --rm --name klipperscreen-remote -v $(PWD)/klipperscreen.sample.conf:/opt/klipperscreen/config/klipperscreen.conf -e DISPLAY="192.168.0.230:0" -e PULSE_SERVER="tcp:192.168.0.230:4713" -e KLIPPERSCREEN_RESTART_DELAY="5" $(IMAGE_NAME)
