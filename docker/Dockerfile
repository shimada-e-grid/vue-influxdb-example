ARG RUBY_VERSION

FROM node:15.8-alpine as node

FROM ruby:${RUBY_VERSION}-alpine

ARG APP_NAME

ENV APP_DIR /home/app
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

WORKDIR /${APP_NAME}

RUN apk update && \
  apk add --no-cache mysql-client mysql-dev tzdata && \
  apk add --no-cache --virtual build-dependencies alpine-sdk python2

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /opt/yarn-* /opt/yarn
RUN ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn

COPY Gemfile Gemfile.lock ./
COPY frontend/package.json frontend/yarn.lock frontend/

# RUN bundle config set clean true
RUN bundle config set path 'vendor/bundle' && \
  bundle install --jobs=4
RUN yarn --cwd frontend install
RUN apk del build-dependencies

COPY . .

# Add a script to be executed every time the container starts.
COPY docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
EXPOSE 8080

# Start the main process.
CMD ["bundle", "exec", "foreman", "start"]
