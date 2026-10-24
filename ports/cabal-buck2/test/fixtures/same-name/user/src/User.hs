module User (user) where

import Tool (greeting)

user :: String
user = greeting ++ " from user"
