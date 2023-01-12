module Zoo.Files where

import Zoo.Prelude

tabFile :: FilePath
tabFile = "/home/dmz/.mozilla/firefox/dmz/sessionstore-backups/recovery.jsonlz4"

outDir :: IsString a => a
outDir = "/home/dmz/.local/share/np-log/"

outLog :: FilePath
outLog = outDir </> "np-log"

outWin :: FilePath
outWin = outDir </> "np-win"

