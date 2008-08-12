{-
Copyright (C) 2002-2008 John Goerzen <jgoerzen@complete.org>

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
module TestParserPrim where
import Data.List
import qualified Test.HUnit as HU
import Test.HUnit.Utils
import Data.Word
import Test.QuickCheck
import TestInfrastructure

import Network.IMAP.Parser.Prim
import Network.IMAP.Types

import TestInfrastructure
import Text.ParserCombinators.Parsec

p parser input = 
    case parse parser "(none)" input of
      Left e -> Left (show e)
      Right y -> Right y

prop_quoted :: String -> Result
prop_quoted s =
    p quoted (gen_quoted s) @?= Right s

gen_quoted :: String -> String
gen_quoted s = '"' : concatMap quoteChar s ++ "\""
    where quoteChar '\\' = "\\\\"
          quoteChar '"' = "\\\""
          quoteChar x = [x]

prop_literal :: String -> Result
prop_literal s =
    p literal (gen_literal s) @?= Right s

gen_literal :: String -> String
gen_literal s =
    "{" ++ show (length s) ++ "}\r\n" ++ s

prop_string3501 :: String -> Bool -> Result
prop_string3501 s True = p string3501 (gen_quoted s) @?= Right s
prop_string3501 s False = p string3501 (gen_literal s) @?= Right s
    
allt = [q "quoted" prop_quoted,
        q "literal" prop_literal,
        q "string3501" prop_string3501
       ]