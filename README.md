# KlipperScreen Remote

_Based on [mkuf](https://github.com/mkuf)'s brilliant [prind](https://github.com/mkuf/prind) project._

[KlipperScreen](https://github.com/jordanruthe/KlipperScreen) for headless environments.

## What is it?

This container image allows you to easily run KlipperScreen in a headless environment, while being able to connect to it remotely using X11 forwarding.

## What's the difference between this and prind?

While this project is technically a fork of [prind](https://github.com/mkuf/prind)'s [KlipperScreen implementation](https://github.com/mkuf/prind/tree/main/docker/klipperscreen), there are a few key differences:

- Designed specifically for headless environments, rendering KlipperScreen on a remote X11 server (such as `XServer XSDL` on Android)
- Automatic restarting of KlipperScreen on failure (user configurable)
- _(more changes are planned for future releases)_

## How do I use this?

```bash
docker \
  run \
    -it \
    --rm \
    --name klipperscreen-remote \
    -v $(PWD)/klipperscreen.sample.conf:/opt/klipperscreen/config/klipperscreen.conf \
    -e DISPLAY="192.168.0.221:0" \
    -e PULSE_SERVER="tcp:192.168.0.221:4713" \
  didstopia/klipperscreen-remote:latest
```

## License

See [LICENSE](LICENSE).
