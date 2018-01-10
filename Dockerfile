FROM ruby:2.5.0-alpine

RUN apk add --no-cache -U \
      tzdata

WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/

RUN bundle install -j4 --deployment --without development test

COPY . /app

ENTRYPOINT ["bundle", "exec", "ruby", "./rdm2bq.rb"]
