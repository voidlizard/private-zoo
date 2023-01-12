module Zoo.Prelude
  ( module System.FilePath.Posix
  , module System.Process.Typed
  , module Control.Concurrent
  , module Control.Monad
  , module System.IO
  , module Prettyprinter
  , module Zoo.Clock
  , module Lens.Micro.Platform
  , atomically
  , qc
  , IsString(..)
  ) where


import Control.Concurrent
import Control.Concurrent.STM (atomically)
import Control.Monad
import Data.String(IsString(..))
import System.FilePath.Posix
import System.IO
import System.Process.Typed
import Text.InterpolatedString.Perl6 (qc)
import Prettyprinter
import Lens.Micro.Platform

import Zoo.Clock

-- import Control.Exception (throwIO)
-- import System.IO (hPutStr, hClose)
-- import qualified Data.ByteString.Lazy as L
-- import qualified Data.ByteString.Lazy.Char8 as L8

