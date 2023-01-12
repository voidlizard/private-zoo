module Main where

import Zoo.Prelude
import Zoo.Files

import Data.Functor
import Data.ByteString.Lazy.Char8 qualified  as L8
import Data.Text.Encoding
import Data.Text.Encoding.Error (ignore)
import Data.Text.IO qualified as Text
import Data.Text qualified as Text
import System.Directory
import System.IO.Error
import Control.Exception
import Safe


-- readLog :: IO [Text]
doMenu :: IO ()
doMenu = do

  let winFile = outDir </> "np-win"

  r <- tryJust (guard . isDoesNotExistError) (readFile winFile)

  let win = either (const Nothing) (readMay) r :: Maybe Int

  let pn = case win of
             Nothing -> []
             Just _  -> [ "pause\tpause", "next\tnext", "" ]

  ls <- L8.readFile outLog <&> take 20  . reverse . L8.lines

  let lss = [ x <> "\tcopy" | x <- ls ]

  let out = L8.intercalate "\n" $ pn  <> lss

  let run = setStdin  (byteStringInput out)  $
            setStdout byteStringOutput $
            setStderr byteStringOutput $
            shell "rofi -dmenu -window-title Яндекс.Музыка -display-columns 1"

  (_,sout,_) <- readProcess run

  let result = decodeUtf8With ignore (L8.toStrict sout) & Text.strip & Text.splitOn "\t"

  case result of
    ["pause",  _]  -> do
      let cmd = [qc|xdotool click --window {pretty win} 1 && xdotool key --window {pretty win} space|]
      putStrLn cmd
      void $
        runProcess (shell cmd)

    ["next",   _]  -> do
      let cmd = [qc|xdotool click --window {pretty win} 1 && xdotool key --window {pretty win} l|]
      void $
        runProcess (shell cmd)

    [s,   "copy"]  -> do
      let enc = byteStringInput (L8.fromStrict (encodeUtf8 s))
      void $
        runProcess_ $ setStdin enc (shell "xsel -i -b")

    _   -> pure ()


main :: IO ()
main = do
  doMenu
