-- | Example: locate the Hackage cache directory.
--
-- This is the @hackage-revdeps@ use case, the lightest consumer of
-- cabal-install: all it needs is the user-level configuration.
--
-- BEFORE (the internal surface, cabal-install <= 3.18):
--
-- > import Distribution.Client.Config    (loadConfig)
-- > import Distribution.Client.GlobalFlags (globalCacheDir)
-- > import Distribution.Client.Setup     (GlobalFlags (..))
--
-- AFTER (the public tier):
--
-- > import Distribution.Client.API.Config
module Main (main) where

import Distribution.Client.API.Config (GlobalConfig (..), loadGlobalConfig)
import Distribution.Verbosity
    ( Verbosity
    , defaultVerbosityHandles
    , mkVerbosity
    , normal
    )
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)

verbosity :: Verbosity
verbosity = mkVerbosity defaultVerbosityHandles normal

main :: IO ()
main = do
    args <- getArgs
    let configFile = case args of
            [f] -> Just f
            _ -> Nothing
    cfg <- loadGlobalConfig verbosity configFile
    case globalCacheDir cfg of
        Just dir -> putStrLn dir
        Nothing -> do
            hPutStrLn stderr "no cache directory configured"
            exitFailure
