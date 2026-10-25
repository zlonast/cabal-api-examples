# cabal-api-examples

Companion examples for the [cabal-install API proposal](https://github.com/haskell/cabal-proposals):
**one executable per real reverse-dependency story**, rebuilt on top of the
public API tier (`Distribution.Client.API.*`). Each example documents in its
header the internal imports the real tool needed before the split — that
diff is the whole point of the proposal.

## The two tiers

| tier | modules | guarantee |
|---|---|---|
| **tier 0** — the tooling API | `API.{Config, PackageIndex, Project, Build}` | breaking changes only in a major release; every export is annotated with the consumer that requested it |
| **tier 1** — the command facades | `API.Command.{Bench, Build, …, Update}` + `API.Flags` | the exact entry points of the built-in commands, re-exported from `cabal-install-internal`; additive-only |

Everything else — the engine and the CLI layer of every command — lives in
`cabal-install-internal`, which moves fast and publishes breaking changes
with every `cabal-install` release (exact-bounds pinning, `ghc-internal`
versioning scheme).

## The examples

| executable | mirrors | uses |
|---|---|---|
| `hackage-cache-dir` | [hackage-revdeps](https://hackage.haskell.org/package/hackage-revdeps) | tier 0: `API.Config` |
| `package-index` | [cabal-matrix](https://hackage.haskell.org/package/cabal-matrix) | tier 0: `API.Config` + `API.PackageIndex` |
| `project-files` | [cabal-add](https://hackage.haskell.org/package/cabal-add) | tier 0: `API.Project` |
| `build-targets` | [cabal-hoogle](https://hackage.haskell.org/package/cabal-hoogle) | tier 0: `API.Build` (`buildTargetsAndDirs`, `runBuild`) |
| `programmatic-cabal` | [hix](https://hackage.haskell.org/package/hix) | tier 1: `API.Command.CmdSdist` + `API.Flags` |

## The real ports (`ports/`)

The actual reverse dependencies, vendored with their migration patches applied
and building against the API branch:

| port | migration |
|---|---|
| `ports/hackage-revdeps` | imports swapped to `API.Config` — nothing else changed |
| `ports/cabal-matrix` | imports swapped to `API.Config` + `API.PackageIndex` |
| `ports/cabal-add` | imports swapped to `API.Project` |
| `ports/cabal-hoogle` | imports swapped to `API.Build` (`BuildOptions`, `buildTargetsAndDirs`, `BuildTarget`) |
| `ports/hix` | **mixed mode**: facade-covered imports moved to `API.Command.{CmdSdist,CmdUpdate}` + `API.Flags`; the solver-facing surface (`IndexUtils`, `SolverInstallPlan`, `Upload`, credentials, `Setup`) deliberately stays on `cabal-install-internal ==3.1900.0` (exact bounds, Step 0 of the admission process). Also carries the fixes for the independent Cabal 3.19 breaking changes (Verbosity rework, `Text` ghc-options, `CondTree` arity, parse-error sources). |
| `ports/cabal-buck2` | **mixed mode**, the same recipe: `NixStyleFlags` via `API.Flags`, everything else (`SetupWrapper`, `ProjectPlanning`, `DistDirLayout`, …) on `cabal-install-internal ==3.1900.0`. The `SetupWrapper` adaptation to the type-indexed `SetupRunnerArgs` (`InLibraryLBI` → `Maybe LocalBuildInfo`) and the Cabal-3.19 `Text` fixes are included. |

All of them build with `cabal build all`; `hix` additionally runs:
`cabal run hix -- --help`, and `cabal-buck2` provides the `cabal buck2`
external command (`cabal-buck2 --help`).

## Building

The examples build against the API branch of cabal checked out as a sibling
directory:

```sh
git clone --branch zlonast/cabal-install-api https://github.com/haskell/cabal cabal
git clone https://github.com/<you>/cabal-api-examples
cd cabal-api-examples
cabal build all
```

## Running

```sh
cabal run hackage-cache-dir            # prints ~/.cabal/packages/... (or your configured cache)
cabal run package-index                # prints available versions of Cabal, text, …
cabal run project-files                # lists the .cabal files of this very project
cabal run build-targets -- cabal-api-examples   # prints the dist dir of each target, builds nothing
cabal run programmatic-cabal           # makes an sdist of this project, like `cabal sdist`
```

`project-files` and `build-targets` operate on the current directory — run
them inside any cabal project (this one works), or point
`project-files` at another checkout via `CABAL_EXAMPLES_PROJECT=/path/to/proj`.
