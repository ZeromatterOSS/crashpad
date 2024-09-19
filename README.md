# Crashpad

[The original repo README can be found here](README.crashpad.md)

This fork of the crashpad repo serves two purposes:

- Adds Bazel build support for Linux
- Vendors dependencies to make the project hermetic. Specifically, Chromium uses git tooling known as [depot_tools](https://chromium.googlesource.com/chromium/tools/depot_tools) to populate sub-repos in the source tree. Only the bare minimum needed to compile the `client` and `crashpad_handler` on linux have been included.
  - `third_party/lss/lss`
  - `third_party/mini_chromium/mini_chromium`
  - `third_party/zlib/zlib`
  - `third_party/curl/curl` (header-only, crashpad `dlopen()`s the host's lib)

These changes are confined to the `zm` branch, and `main` is left to track upstream.

## Setup Guide

To work with this repo, you will first need `depot_tools`. Clone the repo and put it in your PATH via bashrc. The main tool we'll use from it is `gclient`, which is basically an alternative to submodules. `gclient` expects all repos it manages to be in a common working directory. This working directory is configured with the following commands, which will create a `.gclient` file that configures it to pull/sync the crashpad repo, and any dependencies:

```bash
cd ~
mkdir chromium_repos  # choose whatever name you'd like
cd chromium_repos

git clone https://chromium.googlesource.com/chromium/tools/depot_tools

# add the binaries to your PATH
# (yes it actually needs to be in PATH, because commands like `gclient` reference other commands in this directory)
PATH="$(pwd)/depot_tools:$PATH"

# create a .gclient file in this working directory that points to reactors fork of crashpad
gclient config --name crashpad git@github.com:ZeromatterOSS/crashpad.git

# now that we're configured, issue a "sync". This will pull the crashpad repo from reactor and any other chromium deps, as specified in crashpad's DEPS file.
gclient sync
```

Next, you will want setup the `upstream` git remote to pull updates.

```bash
cd ~/chromium_repos/crashpad
git remote add upstream https://chromium.googlesource.com/crashpad/crashpad.git
```

## Pulling from upstream

The `main` branch can be updated simply by checking out and pulling it from `upstream`:

```bash
git checkout main
git pull upstream main
```

To keep ZM changes isolated from upstream, this repo fork has a `zm` branch. It is recommended that the `zm` branch be updated by merging new `main` commits into `zm`:

```
         * (zm)
        /|
(main) * |
       | |
       | *
       |/
       *
       *
       *
       *
```

```bash
git checkout zm
git merge main
```

Once merged, and assuming there are no serious conflicts (good luck), the third_party submodules should be refreshed, likely with `gclient sync`

```bash
# delete the ZM commited deps
rm -rf third_party/lss/lss
rm -rf third_party/mini_chromium/mini_chromium
rm -rf third_party/zlib/zlib

# re-pull the new version of third_party/ repos by running a "sync"
# from the working directory ABOVE crashpad.
cd ../
gclient sync
cd crashpad

# make them not repos
rm -rf third_party/lss/lss/.git
rm -rf third_party/mini_chromium/mini_chromium/.git
rm -rf third_party/zlib/zlib/.git

# commit to the "zm" branch
git commit -m "Re-vender submodule code"
```
