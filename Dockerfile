# Node-RED 5.0.7 on Node 24 — the combination the dependency audit was run against.
# serialport 13 ships prebuilt binaries for Node >=20, so no build toolchain is
# needed at image build time (serialport 9 had prebuilds only up to Node 16,
# which is what pinned this image to the -14 tag).
FROM nodered/node-red:5.0.7-24

# Tells the nibepi core it is running in a container: config writes go
# straight to disk instead of bracketing themselves with sudo mount
# remount,rw to reach a read-only SD card. Bare-Pi installs leave this unset.
ENV NIBEPI_DOCKER=1

COPY nibepi /usr/src/nibepi
COPY node-red-contrib-nibepi /usr/src/node-red-contrib-nibepi

USER root
RUN chown -R node-red /usr/src/nibepi /usr/src/node-red-contrib-nibepi
USER node-red

RUN cd /usr/src/node-red-contrib-nibepi && \
    npm install ../nibepi --omit=dev && \
    cd /usr/src/node-red && \
    npm install ../node-red-contrib-nibepi --omit=dev

RUN npm install node-red-dashboard --omit=dev && \
    npm install node-red-node-ui-list --omit=dev
