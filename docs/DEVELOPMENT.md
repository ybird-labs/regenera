# Development

## Tooling

- `direnv` loads the repo environment through `.envrc`
- `nix` provides the pinned development shell
- `Foundry` is the Solidity toolchain
- `just` is the canonical command runner

## First-time setup

```sh
direnv allow
just bootstrap
```

## Common commands

```sh
just build
just test
just fmt
just fmt-check
just slither
just check
```

## Notes

- Run commands through `just` to keep local usage aligned with CI.
- Solidity dependencies are installed under `lib/` using Foundry.
- CI runs the same checks through Nix and GitHub Actions.
