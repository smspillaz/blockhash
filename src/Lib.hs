module Lib
    ( someFunc
    ) where

import Data.Text as T
import Data.Text.Lazy as L
import Data.Text.Conversions

someFunc = convertText ("someFunc" :: String) :: L.Text
