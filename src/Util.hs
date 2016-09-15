module Util where

import Data.Char (isSpace)
import Data.List (dropWhileEnd)
import Data.Text as Text (unpack, pack, replace)
import System.Exit (ExitCode(..))
import System.Process (readProcessWithExitCode)


-- Wrapper function which simplifies error handling.
readProcess :: FilePath -> [String] -> IO (Maybe String)
readProcess cmd args = do
    (code, stdout, _) <- readProcessWithExitCode cmd args ""
    return $ case code of
        ExitSuccess   -> Just $ rtrim stdout
        ExitFailure _ -> Nothing

rtrim :: String -> String
rtrim = dropWhileEnd isSpace

replace :: String -> String -> String -> String
replace old new s = unpack $ Text.replace (pack old) (pack new) (pack s)

-- Inserts an element between each adjacent pair of elements, whch is the result of applying a function to those elements.
intersperseBy :: (a -> a -> a) -> [a] -> [a]
intersperseBy f (a0:a1:as) = a0 : f a0 a1 : (intersperseBy f $ a1:as)
intersperseBy _ [x] = [x]
intersperseBy _ [] = []

mapBoth :: (a -> b) -> (a, a) -> (b, b)
mapBoth f (x, y) = (f x, f y)

mapFst :: (a -> b) -> (a, c) -> (b, c)
mapFst f (x, y) = (f x, y)

mapSnd :: (b -> c) -> (a, b) -> (a, c)
mapSnd f (x, y) = (x, f y)

-- Applies a function to the first element of a list only.
mapFirst :: (a -> a) -> [a] -> [a]
mapFirst _ [] = []
mapFirst f (x0:xs) = (f x0):xs

-- Applies a function to the last element of a list only.
mapLast :: (a -> a) -> [a] -> [a]
mapLast _ [] = []
mapLast f xs = xs' ++ [f xn] where
    (xs', xn) = splitEnd xs

-- Deconstructs a list into an (init, last) tuple in a single O(n) pass.
splitEnd :: [a] -> ([a], a)
splitEnd [x] = ([], x)
splitEnd (x0:xs) = (x0 : ys, yn) where
    (ys, yn) = splitEnd xs
splitEnd [] = error "splitEnd: empty"

joinEnd :: ([a], a) -> [a]
joinEnd (xs, x) = xs ++ [x]

-- Convenient ADT for defining behaviour in terms of which side of the screen we're rendering to
data Side = SLeft | SRight

side :: a -> a -> Side -> a
side l _ SLeft = l
side _ r SRight = r

oppositeSide :: Side -> Side
oppositeSide = side SRight SLeft

-- Helper infix function for specifying a default. The second argument should always be Just.
withDef :: Maybe a -> Maybe a -> a
withDef (Just x) _ = x
withDef _ (Just x) = x
withDef Nothing Nothing = error "withDef called with two Nothings"

-- Returns the left-most Just, or Nothing.
-- This is different to mappend because Just "a" <> Just "b" == Just "ab". i.e. it composes automatically.
orElse :: Maybe a -> Maybe a -> Maybe a
orElse (Just x) _ = Just x
orElse Nothing (Just x) = Just x
orElse Nothing Nothing = Nothing

