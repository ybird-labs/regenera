# Development

## Local workflow

```sh
direnv allow
just bootstrap
```

`.envrc` loads the Nix flake automatically when you enter the repository.
After that, run project commands through `just`.

## Commands

```sh
just build
just test
just fmt
just fmt-check
just slither
just check
```

## CI

CI keeps Nix explicit and runs the same commands through `just`.
