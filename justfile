set shell := ["bash", "-cu"]

default:
  just --list

bootstrap:
  command -v direnv >/dev/null
  command -v nix >/dev/null
  direnv exec . forge --version
  direnv exec . slither --version

build:
  forge build

test:
  forge test

fmt:
  forge fmt

fmt-check:
  forge fmt --check

clean:
  forge clean

slither:
  slither .

check: fmt-check build test slither

check-ci: fmt-check build test slither
