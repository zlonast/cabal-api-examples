-- | The release of @cabal-buck2@, which the checkout of @haskell-buck2@ (in
-- @buck2\/@) has to be for: it has a branch for each release.
module Distribution.Client.Buck2.Version
  ( cabalBuck2Version
  ) where

import Distribution.Client.Compat.Prelude
import Prelude ()

import Data.Version (showVersion)

import qualified Paths_cabal_buck2

cabalBuck2Version :: String
cabalBuck2Version = showVersion Paths_cabal_buck2.version
