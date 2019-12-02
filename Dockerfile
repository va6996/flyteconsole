FROM node:8 as builder

RUN npm install -g yarn@1.9
WORKDIR /code/flyteconsole
COPY package*.json yarn.lock .snyk ./
RUN : \
  # install production dependencies
  && yarn install --production \
  # move the production dependencies to the /app folder
  && mkdir /app \
  && mv node_modules /app \
  # install development dependencies so we can build
  && yarn install

COPY . .
RUN : \
  # build
  && make build_prod \
  # place the runtime application in /app
  && mv dist corsProxy.js index.js env.js /app

FROM gcr.io/distroless/nodejs
COPY --from=builder /app app
WORKDIR /app
ENV NODE_ENV=production PORT=8080
EXPOSE 8080
CMD ["index.js"]
