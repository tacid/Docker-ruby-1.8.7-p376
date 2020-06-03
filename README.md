# RUBY 1.8.7 docker image

This repo is just for building docker image of ruby-1.8.7 latest avaliable version (p376).

It uses rbenv to compile ruby from official repo
http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8_7/

Preinstalled:
* Rails 2.3.18
* Rake 0.8.7
* I18n 0.6.4
* Bundler 1.6.9

Image can be pulled from hub.docker.com

`
docker pull tacid/docker-ruby-1.8.7:latest
`
