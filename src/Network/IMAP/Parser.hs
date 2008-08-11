{- offlineimap component
Copyright (C) 2008 John Goerzen <jgoerzen@complete.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-}

module Network.IMAP.Parser where
import Text.ParserCombinators.Parsec
import Network.IMAP.Types
import Text.Regex.Posix
import Data.Int

{- | Read a full response from the server. -}
{-
readFullResponse :: Monad m => 
    IMAPConnection m ->         -- ^ The connection to the server
    IMAPString ->               -- ^ The tag that we are awaiting
    m IMAPString
readFullResponse conn expectedtag =
    accumLines []
    where accumLines accum = 
              do line <- getFullLine []
-}

{- | Read a full line from the server, handling any continuation stuff.

FIXME: for now, we naively assume that any line ending in '}\r\n' is
having a continuation piece. -}

getFullLine :: Monad m => 
               IMAPString ->    -- ^ The accumulator (empty for first call)
               IMAPConnection m -> -- ^ IMAP connection
               m IMAPString        -- ^ Result

getFullLine accum conn =
    do input <- readLine conn
       case checkContinuation input of
         Nothing -> return (accum ++ input)
         Just (size) -> 
             do literal <- readBytes conn size
                getFullLine (accum ++ input ++ literal) conn
    where checkContinuation :: String -> Maybe Int64
          checkContinuation i =
              case i =~ "\\{([0-9]+)\\}$" of
                [] -> Nothing
                x -> Just (read x)