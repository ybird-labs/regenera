# Config

Chain-specific values belong in `config/`, not in contract source.

Use one JSON file per deployment target and keep runtime secrets in the
environment, not in committed config files.

## Files

- `example.json` documents the expected shape
- `local.json` is a safe local-development baseline for `anvil`

## Fields

- `network` human-readable network label
- `chainId` target EVM chain id
- `admin` protocol admin address
- `safe` production owner or multisig address
- `treasury` treasury recipient address
- `verify` whether deployment tooling should attempt source verification

## Usage

```sh
CONFIG_PATH=config/local.json forge script script/ValidateConfig.s.sol:ValidateConfigScript
```
