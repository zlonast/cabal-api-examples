-- | Example: read the local Hackage package index.
--
-- This is the @cabal-matrix@ use case: query every known version of a
-- package from the local index without invoking the solver.
--
-- BEFORE (the internal surface):
--
-- > import Distribution.Client.Config          (loadConfig)
-- > import Distribution.Client.GlobalFlags     (withRepoContext)
-- > import Distribution.Client.IndexUtils      (getSourcePackages)
-- > import Distribution.Client.Types.SourcePackageDb (SourcePackageDb (..))
--
-- AFTER (the public tier):
--
-- > import Distribution.Client.API.Config
-- > import Distribution.Client.API.PackageIndex
module Main (main) where

import Distribution.Client.API.Config (loadGlobalConfig)
import Distribution.Client.API.PackageIndex (lookupPackageName, withPackageIndex)
import Distribution.Types.PackageName (mkPackageName)
import Distribution.Verbosity
    ( Verbosity
    , defaultVerbosityHandles
    , mkVerbosity
    , normal
    )
import System.IO (hPutStrLn, stderr)

verbosity :: Verbosity
verbosity = mkVerbosity defaultVerbosityHandles normal

-- Packages whose available versions are printed.
packagesOfInterest :: [String]
packagesOfInterest = ["Cabal", "Cabal-syntax", "text", "lens"]

main :: IO ()
main = do
    cfg <- loadGlobalConfig verbosity Nothing
    withPackageIndex verbosity cfg $ \idx ->
        mapM_ (report idx) packagesOfInterest
  where
    -- the index handle is passed explicitly, not closed over
    report idx name = do
        hPutStrLn stderr ("# " ++ name)
        mapM_ (putStrLn . show) (lookupPackageName idx (mkPackageName name))
