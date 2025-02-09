#!/usr/bin/env bash

setup() {
  export CONFIG_FILE="$(mktemp)"
  export LOG_DIR="$(mktemp -d)"
}

teardown() {
  rm -f "$CONFIG_FILE"
  rm -rf "$LOG_DIR"
}
