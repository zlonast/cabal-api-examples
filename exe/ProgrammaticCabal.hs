-- | Example: invoke a built-in command from Haskell.
--
-- This is the @hix@ use case (tier 1, the \"programmatic cabal\"): call the
-- exact entry point of a built-in command with its real CLI-shaped flags,
-- getting byte-for-byte the behaviour of the command line.
--
-- BEFORE (the internal surface):
--
-- > import Distribution.Client.CmdSdist  (sdistAction)
-- > import Distribution.Client.Setup     (GlobalFlags (..))
-- > import Distribution.Client.ProjectFlags (ProjectFlags (..))
--
-- AFTER (the public tier):
--
-- > import Distribution.Client.API.Command.CmdSdist
-- > import Distribution.Client.API.Flags
module Main (main) where

import Distribution.Client.API.Command.CmdSdist
    ( defaultSdistFlags
    , sdistAction
    )
import Distribution.Client.API.Flags
    ( defaultGlobalFlags
    , defaultProjectFlags
    )
import System.Environment (getArgs)

main :: IO ()
main = do
    -- no arguments: package of the current directory, like @cabal sdist@;
    -- pass a directory to sdist a specific package
    args <- getArgs
    sdistAction (defaultProjectFlags, defaultSdistFlags) args defaultGlobalFlags
