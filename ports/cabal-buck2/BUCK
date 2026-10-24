# Hand-maintained: `cabal buck2` generates BUCK.cabal.bzl, and creates this
# file only if it doesn't exist, so the customisation below is kept.
#
# generated_targets() can be customised (see cabal_targets() in
# buck2/cabal.bzl).
load(":BUCK.cabal.bzl", "generated_targets")

generated_targets(
    overrides = {
        # The test-suite runs the cabal-buck2 executable on the projects in
        # test/fixtures. `cabal test` makes it available on PATH (it's a
        # build-tool-depends of the test-suite), but buck2 only does that for
        # compiling the test, not for running it: so say where it is.
        "fixtures": {
            "test_env": {"CABAL_BUCK2_EXE": "$(exe_target :cabal-buck2-exe)"},
        },
    },
)
