# Image builder definitions

> Highly experimental

Declarative Operating System definitions compilable into osbuild manifests.

## Definition

A single definition is a directory with 2 files in the [Jsonnet format](https://jsonnet.org/): `image.jsonnet` and `manifest.jsonnet`.

The difference between these files is that `image.jsonnet` requires just a blueprint, whereas `manifest.jsonnet` also depends on the result of a depsolver.

### `image.jsonnet`
Contains a function that takes a blueprint as its argument, and returns a high-level description of the image with the following fields:

- `packages` - an object of string lists. Every object is passed to a depsolver separately
- `module_platform_id`
- `repositories` - a list of repositories that the packages will be depsolved against (note that ibdc takes overrides, see below)
- ... more properties useful for higher-level tools


### `manifest.jsonnet`
Contains a function that takes a blueprint, and "sources" as its arguments, and returns an osbuild manifest.

"Sources" are currently an object with one key `org.osbuild.rpm`. This inner object contains two keys:
- `refs` - an object of string lists, its keys correspons to `packages` as defined in `image.jsonnet`. The format of the individual items are osbuild input references. Thus, you can pass this object to inputs of an org.osbuild.rpm stage.
- `sources` a list of items for the `org.osbuild.curl` source.

## Compiler
`ibdc` is a compiler for converting definitions to osbuild manifests. It has two commands: `prepare` and `manifest`.

### `ibdc prepare`
```
./ibdc prepare --type raw --blueprint bp.json --arch x86_64 >bundle.json
```

This command primarily takes `image.jsonnet` and depsolves it. The resulting file is called a "bundle". It contains the passed `--type`, `--blueprint`, `--arch` and the sources object needed for `manifest.jsonnet` (see above). Note that the file also carries the checksum of the used image definition.

### `ibdc manifest`
```
./ibdc manifest bundle.json >manifest.json
```

This command is used convert a bundle into an osbuild manifest. Note that since the bundle contains the checksum of the definition, this command will fail if you modified the definitions between calls to `ibdc prepare` and `ibdc manifest`.

## Useful one-liner

```
./ibdc prepare --type raw --blueprint bp.json --arch x86_64 | ./ibdc manifest -
```

## Current status
Currently, `qcow2` and `raw` images are available. Blueprints supports the following fields:
- `packages` - a list of extra packages
- `customizations.hostname` - a custom hostname
- `customizations.timezone` - a custom timezone
