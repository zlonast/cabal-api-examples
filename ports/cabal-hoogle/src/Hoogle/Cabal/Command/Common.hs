{-# LANGUAGE RecordWildCards #-}

module Hoogle.Cabal.Command.Common
  ( GlobalOptions (..),
    globalOptionsParser,
    hoogleDatabaseArg,
    hoogleDir,
    hoogleBuildOptions,
    defaultVerbosity,
    resolveBuildTargets,
    runHoogleBuild,
  )
where

import Distribution.Client.API.Build
  ( BuildOptions (..),
    BuildTarget,
    buildTargetsAndDirs,
    defaultBuildOptions,
    runBuild,
  )
import qualified Distribution.Verbosity as Verbosity
import Options.Applicative
import System.FilePath ((</>))

data GlobalOptions = GlobalOptions
  { _globalOptions_builddir :: FilePath,
    _globalOptions_version :: Bool
  }
  deriving (Show, Eq)

globalOptionsParser :: Parser GlobalOptions
globalOptionsParser =
  GlobalOptions
    <$> strOption
      ( long "builddir"
          <> value "dist-newstyle/hoogle"
          <> help "Cabal project build dir"
      )
    <*> switch
      ( long "version"
          <> help "Print version"
      )

hoogleDatabaseArg :: String
hoogleDatabaseArg = "--database=all.hoo"

defaultVerbosity :: Verbosity.Verbosity
defaultVerbosity = Verbosity.mkVerbosity Verbosity.defaultVerbosityHandles Verbosity.normal

-- | The directory where the hoogle database lives, derived from @--builddir@.
hoogleDir :: GlobalOptions -> FilePath
hoogleDir GlobalOptions {..} = _globalOptions_builddir </> ".hoogle"

-- | The build options used both for resolving targets and for the actual
-- build: optimized-off build with haddock (in hoogle mode) inside the
-- hoogle build dir.
hoogleBuildOptions :: GlobalOptions -> BuildOptions
hoogleBuildOptions GlobalOptions {..} =
  defaultBuildOptions
    { buildOptBuildDir = Just _globalOptions_builddir,
      buildOptNoOptimisation = True,
      buildOptDocumentation = True,
      buildOptHaddockHoogle = True,
      buildOptHaddockHtml = True,
      buildOptHaddockLinkedSource = True,
      buildOptHaddockQuickJump = True
    }

-- | Resolve the given target strings (default: @all@) to their build
-- directories, without building anything.
resolveBuildTargets :: GlobalOptions -> [String] -> IO [BuildTarget]
resolveBuildTargets go targets =
  buildTargetsAndDirs defaultVerbosity (hoogleBuildOptions go) targets

-- | Build the given targets (default: @all@).
runHoogleBuild :: GlobalOptions -> [String] -> IO ()
runHoogleBuild go targets = runBuild (hoogleBuildOptions go) targets
