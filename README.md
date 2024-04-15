# Image builder definitions

> Highly experimental

Declarative Operating System definitions compilable into osbuild manifests.

## Definition

A single definition is a directory with 2 files in the [Jsonnet format](https://jsonnet.org/): `image.jsonnet` and `manifest.jsonnet`.

The difference between these files is that `image.jsonnet` requires just an image request, whereas `manifest.jsonnet` also depends on the result of a depsolver.

### `image.jsonnet`
Contains a function that takes an (image) request as its argument. The request is an object with the following fields:

- `type` - image type (can be also passed as `--type` to `ibdc prepare`)
- `version` - distribution version (can be also passed as `--version` to `ibdc prepare`)
- `arch` - image architecture (can be also passed as `--type` to `ibdc prepare`)
- `customizations` - an object describing all applicable customizations (at least an empty object is always passed, if it doesn't exist in the original request, `ibdc prepare` creates it)
- `repositories` - overrides the default repositories defined by the image itslef

This file returns a high-level description of the image with the following fields:

- `packages` - an object of string lists. Every object is passed to a depsolver separately
- `module_platform_id`
- `repositories` - a list of repositories that the packages will be depsolved against (caller MUST be able to override these with `request.repositories`, see above)


### `manifest.jsonnet`
Contains a function that takes a request, an image (see `image.jsonnet`), and "sources" as its arguments, and returns an osbuild manifest.

"Sources" are currently an object with one key `org.osbuild.rpm`. This inner object contains two keys:
- `refs` - an object of string lists, its keys correspons to `packages` as defined in `image.jsonnet`. The format of the individual items are osbuild input references. Thus, you can pass this object to inputs of an org.osbuild.rpm stage.
- `sources` a list of items for the `org.osbuild.curl` source.

## Compiler
`ibdc` is a compiler for converting definitions to osbuild manifests. The basic command is `ibdc manifest`:

### `ibdc manifest`
```
./ibdc manifest --type raw --request request.json --arch x86_64 --version 40 >manifest.json
```

This command takes the given request, generates `image.jsonnet`, resolves it, and generates a manifest from `manifest.jsonnet`.


### "Plumbing" commands

Sometimes, more control is needed over the manifest generation process. Thus, three plumbing commands are available:

- `ibdc prepare` - takes the same arguments as `ibdc manifest`, but returns just the processed image before resolving any sources.
- `ibdc resolve` - takes a request and an image, return them together with resolved sources.
- `ibdc finalize` - takes a request, an image and resolved sources, and returns a final osbuild manifest.

These commands can be neatly used in a pipeline:

```
./ibdc prepare --type raw --arch x86_64 --version 40 --request request.json | ./ibdc resolve | ./ibdc finalize
```

This has the same effect as:

```
./ibdc manifest --type raw --arch x86_64 --version 40 --request request.json
```

## Current status
Currently, `qcow2` and `raw` images are available. Blueprints supports the following fields:
- `packages` - a list of extra packages
- `customizations.hostname` - a custom hostname
- `customizations.timezone` - a custom timezone
