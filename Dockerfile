FROM ruby:2.7.2-alpine3.13 AS builder

LABEL maintainer="jeanine@littleforestconsulting.com"

RUN apk update && apk upgrade && apk add --update --no-cache \
  build-base \
  curl-dev \
  git \
  nodejs \
  postgresql-dev \
  tzdata \
  vim \
  yarn && rm -rf /var/cache/apk/*

ARG RAILS_ROOT=/usr/src/app/
WORKDIR $RAILS_ROOT

COPY package*.json yarn.lock $RAILS_ROOT
RUN yarn install --check-files

COPY gems/ $RAILS_ROOT/gems
COPY Gemfile* $RAILS_ROOT
RUN bundle config --global frozen 1 && bundle install

COPY . .

### BUILD STEP DONE ###

FROM ruby:2.7.2-alpine3.13

ARG RAILS_ROOT=/usr/src/app/
ARG USER_ID

RUN apk update && apk upgrade && apk add --update --no-cache \
  bash \
  imagemagick \
  nodejs \
  postgresql-client \
  tzdata \
  vim \
  git \
  openssl \
  fontconfig \
  libwebp \
  yarn && rm -rf /var/cache/apk/*

RUN apk add --update --no-cache --virtual .ms-fonts msttcorefonts-installer && \
 update-ms-fonts 2>/dev/null && \
 fc-cache -f && \
 apk del .ms-fonts

RUN yarn global add heroku

RUN adduser --disabled-password --gecos '' --uid $USER_ID user
USER user

WORKDIR $RAILS_ROOT

COPY --from=builder --chown=user:user $RAILS_ROOT $RAILS_ROOT
COPY --from=builder --chown=user:user /usr/local/bundle/ /usr/local/bundle/

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["bin/rails", "s", "-b", "0.0.0.0"]
