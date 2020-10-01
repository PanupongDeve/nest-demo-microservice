FROM node:12-alpine as builder

USER node
WORKDIR /home/node

COPY . /home/node
RUN id
USER root
RUN apk --no-cache add --virtual native-deps \
  g++ gcc libgcc libstdc++ linux-headers make python && \
  npm install --quiet node-gyp -g &&\
  npm install --quiet && \
  apk del native-deps


USER node
RUN npm install
RUN npm run build

# ---

FROM node:12-alpine

USER root
RUN apk add --no-cache tzdata
ENV TZ Asia/Bangkok

USER node
WORKDIR /home/node
COPY --from=builder /home/node/package*.json /home/node/
COPY --from=builder /home/node/node_modules/ /home/node/node_modules/
COPY --from=builder /home/node/dist/ /home/node/dist/


CMD ["npm","run","start:prod"]
EXPOSE 3000/tcp
