# Debian packaging

A GitHub action to build Ubuntu packages.

## Documentation

### Inputs

#### `dist`

**Required** The name of a Ubuntu version, either code name (e.g. `jammy`)
or release (e.g. `22.04`). Default: `latest`.

#### `sourcepackage`

**Required** The name (and relative path) of the .dsc file.

#### `platform`

The platform to build on. One of `amd64` or `386` (or one of the other
OS/ARCH combinations from <https://hub.docker.com/_/ubuntu> without
leading `linux/`). Defaults to `amd64`.

#### `source_dir`

The path to the directory that contains the .dsc file. Defaults to
the current directory (`.`).

#### `result_dir`

The path to the directory where the built .deb files get copied to.
Defaults to `${source_dir}/artifacts`.

#### `enable_llso`

`true` to enable the llso package repo (<http://linux.lsdev.sil.org>),
otherwise `false`. Defaults to `true`.

#### `enable_pso`

`true` to enable the pso package repo (<http://packages.sil.org>),
otherwise `false`. Defaults to `true`.

#### `deb_fullname`

The full name used for the changelog entry. Defaults to `SIL GHA Packager`.

#### `deb_email`

The email address used for the changelog entry. Defaults to `undelivered@sil.org`.

#### `prerelease_tag`

A pre-release tag to add to the version number. This tag can include the
`GITHUB_RUN_NUMBER` and `GITHUB_RUN_ATTEMPT`, e.g. `~PR-1234-1.1`.

### Example usage

```yaml
...
steps:
  - uses: sillsdev/gha-ubuntu-packaging@v1
    with:
      dist: 'jammy'
      sourcepackage: ${{sourcepackage}}
...
```

See [PACKAGING.md](PACKAGING.md) for a detailed example.

## Manual package builds in a Docker container

The files in this directory also allow to manually build a package in
a docker container.

This can either be done by building a docker image and then running
the `build-package.sh` script inside the docker container, or by using
`local-build.sh` which encapsulates these two steps.

### Using `local-build.sh`

`local-build.sh` takes two mandatory parameters: the Ubuntu version, and
the path and name of the .dsc file to build.

```bash
./local-build.sh jammy ~/ibus/packages/ibus_1.5.26-4sil1.1~jammy.dsc
```

### Building Docker image and running `build-package.sh`

#### 1. Build image

```bash
docker build --build-arg DIST=jammy --build-arg PLATFORM=amd64 -t sillsdev/jammy .
```

`jammy` and `amd64` are the Ubuntu version and platform for which to build the
package.

#### 2. Build binary package

Change into the directory which contains the source package, then run:

```bash
docker run -v $(pwd):/source -i -t -w /source --platform=linux/amd64 \
    sillsdev/jammy jammy ibus_1.5.26-4sil1.1~jammy.dsc .
```

`ibus_1.5.26-4sil1.1~jammy.dsc` is the name of the source package. The
resulting .deb files will be in `$(pwd)/artifacts`.
