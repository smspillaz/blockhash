{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty
import Lib

main = scotty 3000 $ do
  get "/" $ do
    html someFunc
