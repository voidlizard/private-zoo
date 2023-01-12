module Zoo.YandexMusic where

import Control.Applicative
import Control.Monad.Except
import Control.Monad
import Data.ByteString (ByteString)
import Data.ByteString.Lazy qualified as LBS
import Data.Functor
import Data.Generics.Uniplate.Data()
import Data.Generics.Uniplate.Operations
import Data.JsonStream.Parser
import Data.Text (Text)
import System.IO
import Safe


seekSong :: LBS.ByteString -> [Text]
seekSong bs = song
  where
    ss = parseLazyByteString p bs

    song = [ title
           | x@("https://music.yandex.ru/home", title) :: (Text,Text) <- universeBi ss
           ]

    p =
      "windows" .: many ( arrayOf tabs )
      where
        tabs = "tabs" .: many entries
        entries = arrayOf ( "entries" .: items )
        items = many (arrayOf ( (,) <$> "url" .: string <*> "title" .: string  )  )


