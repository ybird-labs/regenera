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
CONFIG_PATH=config/local.json forge script script/ValidateConfig.s.sol:ValidateConfigScript
```

## Config

- Put chain-specific values in `config/`
- Keep secrets in the environment, not in committed JSON files
- Use `config/example.json` as the shape reference

## CI

CI keeps Nix explicit and runs the same commands through `just`.
