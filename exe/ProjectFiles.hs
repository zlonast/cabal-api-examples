-- | Example: enumerate the @.cabal@ files of a project.
--
-- This is the @cabal-add@ use case: discover the packages that make up a
-- project before editing them.
--
-- BEFORE (the internal surface):
--
-- > import Distribution.Client.ProjectConfig
-- >   (findProjectRoot, readProjectConfig, findProjectPackages)
-- > import Distribution.Client.DistDirLayout (defaultDistDirLayout)
-- > import Distribution.Client.RebuildMonad  (runRebuild)
-- > import Distribution.Client.HttpUtils     (configureTransport)
--
-- AFTER (the public tier):
--
-- > import Distribution.Client.API.Project (projectLocalCabalFiles)
module Main (main) where

import Distribution.Client.API.Project (projectLocalCabalFiles)
import Distribution.Verbosity
    ( Verbosity
    , defaultVerbosityHandles
    , mkVerbosity
    , normal
    )
import Data.Maybe (fromMaybe)
import System.Environment (lookupEnv)

verbosity :: Verbosity
verbosity = mkVerbosity defaultVerbosityHandles normal

main :: IO ()
main = do
    -- defaults to this example project itself; point it at any checkout
    dir <- lookupEnv "CABAL_EXAMPLES_PROJECT"
    files <- projectLocalCabalFiles verbosity (fromMaybe "cabal.project" dir)
    mapM_ putStrLn files
