-- | Example: resolve build targets and their build directories.
--
-- This is the @cabal-hoogle@ use case: the read-only part of @cabal build@'s
-- context setup — target selection, solving and plan pruning — without
-- building anything.
--
-- BEFORE (the internal surface):
--
-- > import Distribution.Client.ProjectOrchestration
-- >   (establishProjectBaseContext, withInstallPlan)
-- > import Distribution.Client.ScriptUtils (withContextAndSelectors)
-- > import Distribution.Client.ProjectPlanning (ElaboratedInstallPlan (..))
-- > import Distribution.Client.TargetProblem   (TargetProblem (..))
--
-- AFTER (the public tier):
--
-- > import Distribution.Client.API.Build
module Main (main) where

import Distribution.Client.API.Build
    ( BuildTarget (..)
    , defaultBuildOptions
    , buildTargetsAndDirs
    -- , runBuild  -- to actually build, like @cabal build@
    )
import Distribution.Verbosity
    ( Verbosity
    , defaultVerbosityHandles
    , mkVerbosity
    , normal
    )
import System.Environment (getArgs)

verbosity :: Verbosity
verbosity = mkVerbosity defaultVerbosityHandles normal

main :: IO ()
main = do
    -- an empty target list means "all", like cabal build itself;
    -- pass e.g. "cabal-api-examples" as an argument to be specific
    args <- getArgs
    targets <- buildTargetsAndDirs verbosity defaultBuildOptions args
    mapM_ (putStrLn . buildTargetDistDir) targets
