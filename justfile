set shell := ["bash", "-cu"]

default:
  just --list

bootstrap:
  command -v direnv >/dev/null
  command -v nix >/dev/null
  command -v just >/dev/null
  nix develop -c forge --version
  nix develop -c slither --version

build:
  nix develop -c forge build

test:
  nix develop -c forge test

fmt:
  nix develop -c forge fmt

fmt-check:
  nix develop -c forge fmt --check

clean:
  nix develop -c forge clean

slither:
  nix develop -c slither .

check: fmt-check build test slither

check-ci: fmt-check build test slither
