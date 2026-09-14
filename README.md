# nibepi-docker

Container packaging for NibePi, a Node-RED controller for Nibe F-series heat
pumps.

This repository holds only the image definition. The code lives in two separate
repositories, checked out here as siblings and built into the image:

| directory | repository |
|---|---|
| `nibepi/` | [fnordpojk/nibepi-backend](https://github.com/fnordpojk/nibepi-backend) — the core: protocol, register handling, MQTT |
| `node-red-contrib-nibepi/` | [fnordpojk/node-red-contrib-nibepi](https://github.com/fnordpojk/node-red-contrib-nibepi) — the Node-RED nodes and dashboard logic |

Both are gitignored here.

## Setting up

```sh
git clone https://github.com/fnordpojk/nibepi-docker.git
cd nibepi-docker
git clone https://github.com/fnordpojk/nibepi-backend.git nibepi
git clone https://github.com/fnordpojk/node-red-contrib-nibepi.git
```

The flows are a third repository,
[fnordpojk/nibepi-flow](https://github.com/fnordpojk/nibepi-flow). It is not
built into the image — it is bind-mounted at run time as `/data`, because
Node-RED rewrites `flows.json` whenever you edit the dashboard.

## Building

```sh
docker build -t nibepi-nodered .
```

The image installs the two packages from the local directories rather than from
git, so an edit in either checkout shows up in the next build without committing
anything. That is deliberate: it is the loop for testing against a real pump.

## Running

```sh
docker run -dit --name nibepi --restart unless-stopped \
  -v /opt/nibepi/data/nibepi-flow:/data \
  -v /opt/nibepi/etc/nibepi:/etc/nibepi \
  -v /opt/nibepi/tmp:/tmp \
  -p 1880:1880 \
  -p 9999:9999/udp \
  nibepi-nodered
```

A fixed name means the same command will not simply run again after a
rebuild. Replace the container with:

```sh
docker stop nibepi && docker rm nibepi
```

| mount | holds |
|---|---|
| `/data` | Node-RED's own directory: `flows.json`, `settings.js`, installed nodes. A clone of nibepi-flow. |
| `/etc/nibepi` | NibePi's state: `config.json`, saved graphs, the VV-AI profile. Must persist and must be writable. |
| `/tmp` | `nibepi.log`, the debug log. Mount it only if you want to read the log from the host. |

| port | for |
|---|---|
| `1880/tcp` | the Node-RED editor and dashboard |
| `9999/udp` | inbound frames from the NibeGW gateway |

Outbound, NibePi sends read requests to the gateway on UDP **10000** and writes
on UDP **10001**, from source port 9999. Those need no published port, but the
gateway has to accept them. With
[elupus/esphome-nibe](https://github.com/elupus/esphome-nibe) that means the
Docker host's address must appear in the `source:` list, and `read_port` /
`write_port` must be `10000` / `10001` to match.

## NIBEPI_DOCKER

The image sets `NIBEPI_DOCKER=1`. Without it the core assumes a bare Raspberry Pi
with a read-only SD card and brackets every config write in
`sudo mount -o remount,rw /`, which fails inside a container and loses the write
silently. Bare-Pi installs leave the variable unset.
