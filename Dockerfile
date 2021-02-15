ARG RUBY_VERSION

FROM node:15.8-alpine as node

FROM ruby:${RUBY_VERSION}-alpine

ARG APP_NAME

ENV APP_DIR /home/app
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

WORKDIR ${APP_DIR}/${APP_NAME}

RUN apk update && \
  apk add --no-cache mysql-client mysql-dev tzdata && \
  apk add --no-cache --virtual build-dependencies alpine-sdk python2

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /opt/yarn-* /opt/yarn
RUN ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn

COPY Gemfile Gemfile.lock package.json yarn.lock ./

# RUN bundle config set clean true
RUN bundle config set path 'vendor/bundle' && \
  bundle install --jobs=4
RUN yarn install
RUN apk del build-dependencies

COPY . .

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
