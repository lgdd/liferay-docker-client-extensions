FROM liferay/node-runner:latest

COPY --chown=liferay:liferay client-extensions/node-js /opt/liferay

ENV LIFERAY_ROUTES_DXP=/opt/liferay/dxp-metadata

RUN npm install