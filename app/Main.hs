{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Main where

import Data.Text (unpack)
import Data.Text.Lazy.Encoding  as E

import Web.Scotty
import Lib

import Control.Monad.Trans

import Crypto.Hash

import Network.Wai.Middleware.RequestLogger
import Network.Wai.Middleware.Static
import Network.Wai.Parse

import Network.Ethereum.Web3
import Network.Ethereum.Web3.TH

import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Base16 as B16
import qualified Data.ByteArray as BAConvert
import System.FilePath ((</>))

import Text.Printf

sha256hex :: B.ByteString -> BS.ByteString
sha256hex s = B16.encode $ BAConvert.convert (hashlazy s :: Digest SHA256)

[abiFrom|contracts/build/Blockhash.json|]

main :: IO ()
main = scotty 3000 $ do
  middleware logStdoutDev
  middleware $ staticPolicy (noDots >-> addBase "uploads")

  get "/" $ do
    html someFunc
  post "/upload" $ do
    fs <- files
    let fs' = [ (fieldName, BS.unpack (fileName fi), fileContent fi) | (fieldName, fi) <- fs ]
    -- Not from the usage of 'sequence' here, 'sequence' is used to sequence
    -- together IO actions.
    let results = [ sha256hex fc | (u, fn, fc) <- fs' ]
    let string = BS.concat results
    let stringLazy = B.fromStrict string
    let decoded = E.decodeUtf8 stringLazy

    html decoded

