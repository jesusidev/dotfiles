#!/bin/bash

# Get the initial appearance
last_appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null)

while true; do
  current_appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
  if [ "$current_appearance" != "$last_appearance" ]; then
    pgrep nvim | xargs -I{} kill -SIGUSR1 {}
    last_appearance=$current_appearance
  fi
  sleep 2
done