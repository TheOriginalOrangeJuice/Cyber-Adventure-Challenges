# RowdyCon Theme

This theme can be brought up by itself. You only need:

- this `RowdyCon Theme` folder
- a sibling `Docker-TCP-Switchboard` folder

Example layout:

```text
some-parent/
├── Docker-TCP-Switchboard/
└── RowdyCon Theme/
```

## Prerequisites

- Linux host
- Docker Engine
- Docker Compose plugin
- Bash

The switchboard container uses host networking, so use a Linux Docker host.

## Quick start

```bash
cd "RowdyCon Theme"
./labctl.sh up
```

That command:

1. Builds all RowdyCon challenge images with stable tags.
2. Starts the RowdyCon support stack from `Hack/Box 1/docker-compose.yml`.
3. Generates `.generated/switchboard/current.conf`.
4. Starts the switchboard container.

## Common commands

```bash
./labctl.sh build
./labctl.sh generate-config
./labctl.sh up
./labctl.sh down
./labctl.sh status
./labctl.sh generate-service
```

What each command does:

- `./labctl.sh build`
  Builds every challenge image for this theme, but does not start any containers.
- `./labctl.sh generate-config`
  Writes the switchboard config to `.generated/switchboard/current.conf` using this theme's image tags, networks, ports, and evidence mount.
- `./labctl.sh up`
  Runs the full workflow: build theme images, start the support stack, generate the switchboard config, and start the switchboard container.
- `./labctl.sh down`
  Stops the switchboard container and the theme support stack.
- `./labctl.sh status`
  Shows the relevant running containers for this theme so you can confirm the stack is up.
- `./labctl.sh generate-service`
  Renders a ready-to-install systemd unit into `.generated/systemd/` with this theme folder's absolute path filled in.

## Optional changes

If `Docker-TCP-Switchboard` is not next to this folder, point to it explicitly:

```bash
SWITCHBOARD_DIR=/path/to/Docker-TCP-Switchboard ./labctl.sh up
```

You can also change the public port range or bind address:

```bash
SWITCHBOARD_PORT_BASE=41000 SWITCHBOARD_BIND_ADDRESS=127.0.0.1 ./labctl.sh up
```

Supported environment overrides:

- `SWITCHBOARD_DIR`
  Tells `labctl.sh` where to find the `Docker-TCP-Switchboard` folder if it is not a sibling of this theme folder.
- `SWITCHBOARD_PORT_BASE`
  Changes the first public SSH port used by the switchboard. The remaining challenge ports are allocated sequentially from that base.
- `SWITCHBOARD_BIND_ADDRESS`
  Restricts the switchboard listeners to a specific interface, for example `127.0.0.1` for local-only access.
- `SWITCHBOARD_LOG_LEVEL`
  Sets the generated switchboard config log level, for example `INFO` or `DEBUG`.

## Generated files

```text
.generated/switchboard/current.conf
.generated/state/docker-tcp-switchboard.log
.generated/systemd/cyber-adventure-rowdycon.service
```

## Optional systemd setup

```bash
./labctl.sh generate-service
sudo cp .generated/systemd/cyber-adventure-rowdycon.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now cyber-adventure-rowdycon.service
```

## Notes

- The challenge content is unchanged; this only automates the build-and-run workflow.
- The CTFd backup remains in this theme folder, but restoring CTFd is still a separate step.
