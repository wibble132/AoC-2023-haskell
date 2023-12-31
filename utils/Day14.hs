module Day14 (part1, part2) where

import Data.Hashable (hash)
import Data.List (elemIndex)
import Data.Maybe (fromJust)
import Data.Set (Set, empty, insert, member)
import Utils (withOneIndex, fPow, fPow')

-- 111979
part1 :: String -> String
part1 = show . weight . rollStonesNorth . lines

-- 102193 Too high -- multiple off-by-one in calculating equivalent to billion
-- 102055 Correct :)
part2 :: String -> String
part2 s = show $ weight billionStones
  where
    input = lines s
    dup = (lines . fromJust . firstDupOn hash . map unlines . rollCycles) input
    idx1 = fromJust (dup `elemIndex` tail (rollCycles input)) + 1
    idxDiff = fromJust (dup `elemIndex` tail (rollCycles dup)) + 1
    billionModDiff = 1000000000 `mod` idxDiff
    billion = head $ filter (>= idx1) [billionModDiff, billionModDiff + idxDiff ..]
    billionStones = rollCycles input !! billion

rollStonesEast :: [[Char]] -> [[Char]]
rollStonesEast = fPow 100 (map rollLineEast)
  where
    rollLineEast :: [Char] -> [Char]
    rollLineEast ('.' : 'O' : ss) = 'O' : rollLineEast ('.' : ss)
    rollLineEast (c : ss) = c : rollLineEast ss
    rollLineEast [] = []

rollStonesNorth :: [[Char]] -> [[Char]]
rollStonesNorth = transpose . rollStonesEast . transpose

transpose :: [[a]] -> [[a]]
transpose ([] : _) = []
transpose x = map head x : transpose (map tail x)

weight :: [[Char]] -> Integer
weight = sum . map (lineWeight . reverse) . transpose
  where
    lineWeight :: [Char] -> Integer
    lineWeight = sum . map fst . filter ((== 'O') . snd) . withOneIndex

rollCycle :: [[Char]] -> [[Char]]
rollCycle = fPow' 4 (rotate . rollStonesNorth)

rollCycles :: [[Char]] -> [[[Char]]]
rollCycles c = c : rollCycles (rollCycle c)

rotate :: [[a]] -> [[a]]
rotate = map reverse . transpose

firstDupOn :: (Ord b) => (a -> b) -> [a] -> Maybe a
firstDupOn _f l = go _f l empty
  where
    go :: (Ord b) => (a -> b) -> [a] -> Set b -> Maybe a
    go _ [] _ = Nothing
    go f (x : xs) s
      | f x `member` s = Just x
      | otherwise = go f xs (f x `insert` s)