# cabal-api-examples

The reverse dependencies of `cabal-install`-the-library, vendored with their
migration patches to the public API tier (`Distribution.Client.API.*`) of the
[cabal-install API proposal](https://github.com/haskell/cabal-proposals).
Every port's diff is the whole point of the proposal: the internal imports
the tool needed before the split, replaced by the API.

## The two tiers

| tier | modules | guarantee |
|---|---|---|
| **tier 0** — the tooling API | `API.{Config, PackageIndex, Project, Build}` | breaking changes only in a major release; every export is annotated with the consumer that requested it |
| **tier 1** — the command facades | `API.Command.{Bench, Build, …, Update}` + `API.Flags` | the exact entry points of the built-in commands, re-exported from `cabal-install-internal`; additive-only |

Everything else — the engine and the CLI layer of every command — lives in
`cabal-install-internal`, which moves fast and publishes breaking changes
with every `cabal-install` release (exact-bounds pinning, `ghc-internal`
versioning scheme).

## The ports (`ports/`)

The actual reverse dependencies, vendored with their migration patches applied
and building against the API branch:

| port | migration |
|---|---|
| `ports/hackage-revdeps` | imports swapped to `API.Config` — nothing else changed |
| `ports/cabal-matrix` | imports swapped to `API.Config` + `API.PackageIndex` |
| `ports/cabal-add` | imports swapped to `API.Project` |
| `ports/cabal-hoogle` | imports swapped to `API.Build` (`BuildOptions`, `buildTargetsAndDirs`, `BuildTarget`) |
| `ports/hix` | **mixed mode**: facade-covered imports moved to `API.Command.{CmdSdist,CmdUpdate}` + `API.Flags`; the solver-facing surface (`IndexUtils`, `SolverInstallPlan`, `Upload`, credentials, `Setup`) deliberately stays on `cabal-install-internal ==3.1900.0` (exact bounds, Step 0 of the admission process). Also carries the fixes for the independent Cabal 3.19 breaking changes (Verbosity rework, `Text` ghc-options, `CondTree` arity, parse-error sources). |
| `ports/guardian` | **mixed mode**: `updateAction` via `API.Command.CmdUpdate` and `defaultNixStyleFlags` via `API.Flags`; the orchestration/plan surface (`InstallPlan`, `ProjectOrchestration`, `ProjectPlanning`, `ProjectRoot`) stays on `cabal-install-internal ==3.1900.0` (exact bounds, Step 0). Vendored from the upstream GitHub tree (last change 2025-09), the sixth rdep — previously excluded as inactive. |
| `ports/cabal-buck2` | **mixed mode**, the same recipe: `NixStyleFlags` via `API.Flags`, everything else (`SetupWrapper`, `ProjectPlanning`, `DistDirLayout`, …) on `cabal-install-internal ==3.1900.0`. The `SetupWrapper` adaptation to the type-indexed `SetupRunnerArgs` (`InLibraryLBI` → `Maybe LocalBuildInfo`) and the Cabal-3.19 `Text` fixes are included. |
| `ports/cabal-solver-plan` | **Step 0** (plan producer): drives `modularResolver` directly and renders the resolution as JSON — its contract is the solver's own data, which the tier deliberately does not cover. Migration = package swap (`cabal-install` → `cabal-install-internal ==3.1900.0`) plus the Cabal-3.19 `PreferVersion` rework (`PreferOldest` became a constructor). |
| `ports/make-install-plan` | **Step 0** (plan producer): haskell.nix's `nix-tools` slice (`make-install-plan` executable + the `cabal2nix` library), the deepest known consumer — it reuses the real planning pipeline (`rebuildInstallPlan`, `ElaboratedConfiguredPackage`) and serialises the elaborated plan for Nix. Migration = package swap (`cabal-install` → `cabal-install-internal ==3.1900.0`) plus the independent Cabal-3.19 breaking changes: `CondTree` lost its constraint parameter, the `Verbosity` rework (`mkVerbosity`/`VerbosityFlags`), `BuildInfo` `Text` fields, `PErrorWithSource`, `SetupCliVersion`, `ProjectFileKey`, and the two-argument `topHandler`. Builds against `hnix-0.17.0` with its stale bounds relaxed (see its `cabal.project`). |

All of them build with `cabal build all`; `hix` additionally runs:
`cabal run hix -- --help`, and `cabal-buck2` provides the `cabal buck2`
external command (`cabal-buck2 --help`).

## Building

The ports build against the API branch of cabal checked out as a sibling
directory. The root project contains only the engine packages and `hix`;
every other port carries its own `cabal.project` and builds separately,
so one port's stale dependencies cannot spill into a shared install plan:

```sh
git clone --branch zlonast/cabal-install-api https://github.com/haskell/cabal cabal
git clone https://github.com/zlonast/cabal-api-examples
cd cabal-api-examples
cabal build all                          # engine + hix
cd ports/cabal-solver-plan && cabal build all   # a port, in isolation
```

`ports/make-install-plan` additionally pins `hnix ==0.17.0` and relaxes its
stale bounds (see the comments in its `cabal.project`), the same recipe as
`guardian`'s stale-base `allow-newer`s.

