"""
Thin wrappers around cc_library/cc_binary for Crashpad's first-party targets.
Third-party code (zlib) and header-only targets use plain cc_library.
"""

load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")

# Crashpad requires >=C++20. Because parent bazel projects may set
# `--cxxopt=-std=`, we override it here by using per-target copts, which are
# placed after the global cxxopts on the command line.
_CRASHPAD_COPTS = ["-std=c++20"]

# crashpad_flock_always_supported = !(crashpad_is_android || crashpad_is_fuchsia)
# (build/crashpad_buildconfig.gni)
_CRASHPAD_DEFINES = select({
    "@platforms//os:android": [],
    "@platforms//os:fuchsia": [],
    "//conditions:default": ["CRASHPAD_FLOCK_ALWAYS_SUPPORTED=1"],
})

def crashpad_cc_library(copts = [], defines = [], **kwargs):
    cc_library(
        copts = _CRASHPAD_COPTS + copts,
        defines = _CRASHPAD_DEFINES + defines,
        **kwargs
    )

def crashpad_cc_binary(copts = [], defines = [], **kwargs):
    cc_binary(
        copts = _CRASHPAD_COPTS + copts,
        defines = _CRASHPAD_DEFINES + defines,
        **kwargs
    )
