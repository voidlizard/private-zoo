module Zoo.Clock
  ( module System.Clock
  )where

import Control.Monad.IO.Class
import Data.Fixed
import Data.Int (Int64)
import Prettyprinter
import System.Clock
import Control.Concurrent (threadDelay)

data TimeoutKind = MilliSeconds | Seconds | Minutes

data family Timeout ( a :: TimeoutKind )


newtype Wait a = Wait a
                 deriving newtype (Eq,Show,Pretty)

newtype Delay a = Delay a
                  deriving newtype (Eq,Show,Pretty)



class IsTimeout a where
  toNanoSeconds :: Timeout a -> Int64

  toMicroSeconds :: Timeout a -> Int
  toMicroSeconds x = fromIntegral $ toNanoSeconds x `div` 1000

  toTimeSpec    :: Timeout a -> TimeSpec
  toTimeSpec x = fromNanoSecs (fromIntegral (toNanoSeconds x))

class IsTimeout a => MonadPause m a where
  pause :: Timeout a -> m ()

instance (IsTimeout a, MonadIO m) => MonadPause m a where
  pause x = liftIO $ threadDelay (toMicroSeconds x)

instance Pretty (Fixed E9) where
  pretty = pretty . show


newtype instance Timeout 'MilliSeconds =
  TimeoutMSec (Fixed E9)
  deriving newtype (Eq,Ord,Num,Real,Fractional,Show,Pretty)

newtype instance Timeout 'Seconds =
  TimeoutSec (Fixed E9)
  deriving newtype (Eq,Ord,Num,Real,Fractional,Show,Pretty)

newtype instance Timeout 'Minutes =
  TimeoutMin (Fixed E9)
  deriving newtype (Eq,Ord,Num,Real,Fractional,Show,Pretty)

instance IsTimeout 'MilliSeconds where
  toNanoSeconds (TimeoutMSec x) = round (x * 1e6)

instance IsTimeout 'Seconds where
  toNanoSeconds (TimeoutSec x) = round (x * 1e9)

instance IsTimeout 'Minutes where
  toNanoSeconds (TimeoutMin x) = round (x * 60 * 1e9)

