FROM nodered/node-red:3.0.2-14
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

