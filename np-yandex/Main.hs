module Main where

import Zoo.Prelude
import Zoo.Files
import Zoo.YandexMusic

import Control.Monad.IO.Class
import Control.Monad.Except
import Data.Functor
import Data.Char (isDigit)
import Data.ByteString.Lazy qualified as L
import Data.ByteString.Lazy.Char8 qualified  as L8
import Data.Text qualified as Text
import Data.Text.IO qualified as Text
import Data.Text (Text)
import Data.Cache (Cache)
import Data.Cache qualified as Cache
import Data.Maybe

import Control.Concurrent.STM.TChan qualified as TChan
import Control.Concurrent.STM.TChan (TChan)
import Control.Concurrent.Async as Async
import System.Directory
import Data.Int
import Safe

import Data.IORef as IORef

import System.INotify

-- var tabfile = /home/dmz/.mozilla/firefox/dmz/sessionstore-backups/recovery.jsonlz4
-- outFile = /home/dmz/.local/share/np-log/np-log
-- var outdir = (path:dir $outfile)
-- var outwinfile = $outdir/win-id


main :: IO ()
main = do

  createDirectoryIfMissing True outDir

  hSetBuffering stdout LineBuffering

  chan <- TChan.newTChanIO :: IO (TChan Bool)
  chanSeeker <- TChan.newTChanIO :: IO (TChan Text)
  wcache <- Cache.newCache (Just (toTimeSpec @'Seconds 10)) :: IO (Cache Bool Int)

  lastIO <- IORef.newIORef Nothing

  withINotify $ \inotify -> do

    let mask = [ CloseWrite, MoveSelf, MoveIn, Move, Modify ]

    void $ addWatch  inotify mask [qc|{tabFile}|] $ \_ -> do
      atomically $ TChan.writeTChan chan True

    winseekers <- async $ forever $ do
      what <- atomically $ TChan.readTChan chanSeeker

      win' <- Cache.lookup wcache True

      let cmd = [qc|xdotool search "{pretty what}"|]
      let run = setStdin createPipe $
                setStdout byteStringOutput $
                setStderr byteStringOutput $
                shell cmd

      (_,sout,_) <- readProcess run


      let wnum = (readMay @Int . L8.unpack . L8.takeWhile isDigit) sout

      case wnum of
        Just w -> Cache.insert wcache True w >> writeFile outWin (show w)
        _      -> writeFile outWin "" >> threadDelay 2000000

    scanner <- async $ forever $ do
        _ <- Async.race (void $ atomically $ TChan.readTChan chan) (threadDelay 2000000)
        s <- readProcessStdout_ $ shell [qc|dejsonlz4 {tabFile} | jq|]
        lastp <- IORef.readIORef lastIO
        let mnp = listToMaybe $ seekSong s

        case mnp of
          Nothing -> do
            IORef.writeIORef lastIO mnp
            atomically $ TChan.writeTChan chanSeeker "Яндекс Музыка"

          Just np -> do
            unless (mnp == lastp) $ do
              IORef.writeIORef lastIO mnp

              let pp = Text.take 50 $ if Text.isPrefixOf "Яндекс" np then "silence" else np

              atomically $ TChan.writeTChan chanSeeker np

              Text.putStrLn pp
              Text.appendFile outLog (pp <> "\n")


    void $  waitAnyCatchCancel [scanner,winseekers]


