-- | Set up the project for building with @buck2@
module Distribution.Client.Buck2.Setup
  ( checkBuck2Prelude
  , ensureBuckconfigAndPackage
  ) where

import Distribution.Client.Compat.Prelude
import Prelude ()

import Data.List (stripPrefix)
import System.Directory (doesDirectoryExist, doesFileExist)
import System.FilePath ((</>))

import Distribution.Simple.Utils (die', notice)

import Distribution.Client.Buck2.Version (cabalBuck2Version)


-- | Check that the @buck2@ support code is at @buck2\/@, and that it is for
-- this release of @cabal-buck2@: the files it generates are only understood by
-- the same release of it, which is a branch of that name.
checkBuck2Prelude :: Verbosity -> FilePath -> IO ()
checkBuck2Prelude verbosity projectRoot = do
  exists <- doesDirectoryExist buck2Dir
  unless exists $
    die' verbosity $
      unlines
        [ "No 'buck2/' directory found in the project root."
        , "Clone the buck2 prelude and support scripts with:"
        , ""
        , "    git clone --branch " ++ cabalBuck2Version ++ " https://github.com/simonmar/haskell-buck2 buck2"
        , ""
        , "then re-run 'cabal buck2'."
        ]
  found <- readBuck2Version buck2Dir
  case found of
    Just v | v == cabalBuck2Version -> return ()
    _ ->
      die' verbosity $
        unlines
          [ "The 'buck2/' directory is not for this release of cabal-buck2."
          , ""
          , "This is cabal-buck2 " ++ cabalBuck2Version ++ ", and buck2/ is for " ++ maybe "no release (it is from an earlier one)" ("cabal-buck2 " ++) found ++ "."
          , ""
          , "cabal-buck2 " ++ cabalBuck2Version ++ " needs the " ++ cabalBuck2Version ++ " branch of https://github.com/simonmar/haskell-buck2. If buck2/ is a git checkout, switch it with:"
          , ""
          , "    git -C buck2 fetch && git -C buck2 checkout " ++ cabalBuck2Version
          , ""
          , "or use the cabal-buck2 release that matches the buck2/ you have."
          ]
  where
    buck2Dir = projectRoot </> "buck2"

-- | The release of @cabal-buck2@ that a checkout of @haskell-buck2@ is for,
-- from its @version.bzl@ (@CABAL_BUCK2_VERSION = "..."@).
readBuck2Version :: FilePath -> IO (Maybe String)
readBuck2Version buck2Dir = do
  let path = buck2Dir </> "version.bzl"
  exists <- doesFileExist path
  if not exists
    then return Nothing
    else do
      contents <- readFile path
      return $ listToMaybe [takeWhile (/= '"') rest | l <- lines contents, Just rest <- [stripPrefix "CABAL_BUCK2_VERSION = \"" l]]

-- | Copy @.buckconfig@ and @PACKAGE@ if they don't exist
ensureBuckconfigAndPackage :: Verbosity -> FilePath -> IO ()
ensureBuckconfigAndPackage verbosity projectRoot = do
  copyIfMissing verbosity (templateDir </> ".buckconfig") (projectRoot </> ".buckconfig")
  copyIfMissing verbosity (templateDir </> "PACKAGE") (projectRoot </> "PACKAGE")
  where
    templateDir = projectRoot </> "buck2" </> "template"

copyIfMissing :: Verbosity -> FilePath -> FilePath -> IO ()
copyIfMissing verbosity src dest = do
  exists <- doesFileExist dest
  unless exists $ do
    contents <- readFile src
    writeFile dest contents
    notice verbosity $ "cabal buck2: created " ++ dest ++ " (from " ++ src ++ ")"
