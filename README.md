# Swift Testing Frameworks Comparison

## Build

```sh
make build
```

If `~/.local/bin` is not on your `PATH`, the build step adds it to `~/.zshrc` — restart your shell or run `source ~/.zshrc` once before continuing.

## Generate a system report

Before running benchmarks, record the device:

```sh
testbench report --generate
```

## Run

```sh
testbench xctest
```

## Uninstall

```sh
make remove
```

## Help

```sh
testbench --help
testbench help <subcommand>
```
