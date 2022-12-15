# Creating Ubuntu packages with GitHub Actions

This document describes the necessary steps to create Ubuntu packages
with GitHub Actions and upload them to llso.

## Example

For a full working example where this is used in real-live, check the
Keyman [deb-packaging workflow](https://github.com/keymanapp/keyman/blob/master/.github/workflows/deb-packaging.yml).

## Preparations

- in the settings of the GitHub project for which you want to create
  packages, add a `deploy` environment that only allows the protected
  branches. Add two environment secrets:
  - **DEBSIGN_KEYID**. This is the GPG key id used to sign and upload
    the packages
  - **GPG_SIGNING_KEY**. The base64 encoded private GPG key used for
    signing and uploading packages. This can be done with the following
    command:

    ```bash
    gpg --export-secret-keys YOUR_ID_HERE | base64
    ```

## Workflow

- In your GitHub project create a workflow
- add a job that generates a source package. This can be as easy
  as the following lines:

  ```yml
      - name: Build source package
        run: |
          debuild -D -sa -Zxz
  ```

- you might also want to set the version and a pre-release tag as output
  parameters

- add a matrix job for the dists you're trying to build
- add a step with the gha-ubuntu-packaging action, passing the dist,
  platform, and source package

  ```yml
  binary_packages:
    name: Build binary packages
    needs: sourcepackage
    strategy:
      fail-fast: true
      matrix:
        dist: [focal, jammy, kinetic]
        arch: [amd64]

    runs-on: ubuntu-latest
    steps:
    - name: Download Artifacts
      uses: actions/download-artifact@fb598a63ae348fa914e94cd0ff38f362e927b741 # v3.0.0
      with:
        path: artifacts

    - name: Build
      uses: sillsdev/gha-ubuntu-packaging@v0.2
      with:
        dist: "${{ matrix.dist }}"
        platform: "${{ matrix.arch }}"
        source_dir: "artifacts/my-srcpkg"
        sourcepackage: "my${{ needs.sourcepackage.outputs.VERSION }}-1.dsc"
        prerelease_tag: ${{ needs.sourcepackage.outputs.PRERELEASE_TAG }}

    - name: Store binary packages
      uses: actions/upload-artifact@3cea5372237819ed00197afe530f5a7ea3e805c8 # v3.1.0
      with:
        name: my-binarypkgs
        path: |
          artifacts/*
          !artifacts/my-srcpkg/
  ```

- add a job for signing the packages that makes use of the `deploy` environment.
  This is necessary so that this job doesn't run for pull requests which might
  expose secrets.
  - You can use [gha-deb-signing](https://github.com/sillsdev/gha-deb-signing)
    for that.

  ```yml
  deb_signing:
    name: Sign source and binary packages
    needs: [sourcepackage, binary_packages]
    runs-on: ubuntu-latest
    environment: deploy

    steps:
      - name: Sign packages
        uses: sillsdev/gha-deb-signing@c035bafb5cd334191b6943d063743a619750b016 # v0.1
        with:
          src-pkg-path: "artifacts/my-srcpkg"
          src-pkg-name: "my${{ needs.sourcepackage.outputs.VERSION }}-1_source.changes"
          bin-pkg-path: "artifacts/my-binarypkgs"
          bin-pkg-name: "my${{ needs.sourcepackage.outputs.VERSION }}-1${{ needs.sourcepackage.outputs.PRERELEASE_TAG }}+"
          artifacts-name: "my-signedpkgs"
          gpg-signing-key: "${{ secrets.GPG_SIGNING_KEY }}"
          debsign-keyid: "${{ secrets.DEBSIGN_KEYID }}"
  ```
