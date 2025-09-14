#!/usr/bin/env bash

sudo apt-get update  --yes;
sudo apt-get upgrade --yes;

sudo apt-get install --yes \
  bash                     \
  curl                     \
  diffutils                \
  findutils                \
  git                      \
  grep                     \
  gzip                     \
  lynx                     \
  net-tools                \
  nginx                    \
  openssh-server           \
  wget                     \
  jq                       \
;
