FROM elafo/dev-base:debian-jessie
MAINTAINER eLafo

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
ENV RUBY_VERSION 2.3.3
RUN \curl -sSL https://get.rvm.io | bash -s stable --ruby=$RUBY_VERSION

VOLUME $USER_HOME/.rvm/gems/ruby-$RUBY_VERSION
